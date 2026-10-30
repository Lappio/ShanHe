package com.shanhe.portal;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.shanhe.portal.common.BizException;
import com.shanhe.portal.dto.TicketSaveDTO;
import com.shanhe.portal.entity.TicketType;
import com.shanhe.portal.mapper.TicketTypeMapper;
import com.shanhe.portal.service.OrderService;
import com.shanhe.portal.service.SpotService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class FixRoundTest {
    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private ObjectMapper objectMapper;
    @Autowired
    private JdbcTemplate jdbc;
    @Autowired
    private OrderService orderService;
    @Autowired
    private SpotService spotService;
    @Autowired
    private TicketTypeMapper ticketTypeMapper;

    @Test
    void disabledUserTokenIsRejectedAndNewLoginWorks() throws Exception {
        String token = login("admin", "admin123");
        jdbc.update("UPDATE `user` SET status = 0 WHERE username = 'admin'");
        try {
            mockMvc.perform(get("/api/admin/stats").header("Authorization", "Bearer " + token))
                    .andExpect(status().isUnauthorized());
            mockMvc.perform(get("/api/auth/me").header("Authorization", "Bearer " + token))
                    .andExpect(status().isUnauthorized());
        } finally {
            jdbc.update("UPDATE `user` SET status = 1 WHERE username = 'admin'");
        }
        String again = login("admin", "admin123");
        mockMvc.perform(get("/api/admin/stats").header("Authorization", "Bearer " + again))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0));
    }

    @Test
    void passwordChangeRevokesOldToken() throws Exception {
        String oldHash = jdbc.queryForObject("SELECT password FROM `user` WHERE username = 'linwan'", String.class);
        Integer oldVersion = jdbc.queryForObject("SELECT token_version FROM `user` WHERE username = 'linwan'", Integer.class);
        String token = login("linwan", "user123");
        try {
            mockMvc.perform(put("/api/user/password")
                            .header("Authorization", "Bearer " + token)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"oldPassword\":\"user123\",\"newPassword\":\"user1234\"}"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.code").value(0));
            mockMvc.perform(get("/api/auth/me").header("Authorization", "Bearer " + token))
                    .andExpect(status().isUnauthorized());
            String fresh = login("linwan", "user1234");
            mockMvc.perform(get("/api/auth/me").header("Authorization", "Bearer " + fresh))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data.username").value("linwan"));
        } finally {
            jdbc.update("UPDATE `user` SET password = ?, token_version = ? WHERE username = 'linwan'", oldHash, oldVersion);
        }
    }

    @Test
    void demotedAdminTokenGetsForbidden() throws Exception {
        jdbc.update("DELETE FROM `user` WHERE username = 'round4tmp'");
        jdbc.update(
                "INSERT INTO `user` (username, password, nickname, role, status, token_version) "
                        + "SELECT 'round4tmp', password, '临时管理员', 'ADMIN', 1, 0 FROM `user` WHERE username = 'linwan'");
        try {
            String admin = login("admin", "admin123");
            String token = login("round4tmp", "user123");
            Long id = jdbc.queryForObject("SELECT id FROM `user` WHERE username = 'round4tmp'", Long.class);
            mockMvc.perform(put("/api/admin/users/" + id)
                            .header("Authorization", "Bearer " + admin)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"role\":\"USER\",\"status\":1}"))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.code").value(0));
            mockMvc.perform(get("/api/admin/stats").header("Authorization", "Bearer " + token))
                    .andExpect(status().isForbidden());
        } finally {
            jdbc.update("DELETE FROM `user` WHERE username = 'round4tmp'");
        }
    }

    @Test
    void cancelledOrderCannotBeRestored() {
        Long id = jdbc.queryForObject(
                "SELECT id FROM booking_order WHERE status = 'CANCELLED' ORDER BY id LIMIT 1", Long.class);
        BizException pending = assertThrows(BizException.class, () -> orderService.adminStatus(id, "PENDING"));
        BizException completed = assertThrows(BizException.class, () -> orderService.adminStatus(id, "COMPLETED"));
        String status = jdbc.queryForObject("SELECT status FROM booking_order WHERE id = ?", String.class, id);
        assertEquals("CANCELLED", status);
        assertTrue(pending.getMessage().contains("待出行"));
        assertTrue(completed.getMessage().contains("待出行"));
    }

    @Test
    void completeAndCancelRaceOnlyOneWins() throws Exception {
        Long userId = jdbc.queryForObject("SELECT id FROM `user` WHERE username = 'linwan'", Long.class);
        jdbc.update(
                "INSERT INTO booking_order (order_no, user_id, spot_id, ticket_type_id, visit_date, quantity, "
                        + "unit_price, total_amount, contact_name, contact_phone, status) "
                        + "VALUES ('SHROUND4RACE', ?, 1, 1, '2099-01-01', 1, 10, 10, 'race', '13800001001', 'PENDING')",
                userId);
        Long id = jdbc.queryForObject("SELECT id FROM booking_order WHERE order_no = 'SHROUND4RACE'", Long.class);
        ExecutorService pool = Executors.newFixedThreadPool(2);
        CountDownLatch start = new CountDownLatch(1);
        AtomicInteger wins = new AtomicInteger();
        AtomicInteger rejects = new AtomicInteger();
        try {
            Future<?> complete = pool.submit(() -> race(start, () -> orderService.adminStatus(id, "COMPLETED"), wins, rejects));
            Future<?> cancel = pool.submit(() -> race(start, () -> orderService.adminStatus(id, "CANCELLED"), wins, rejects));
            start.countDown();
            complete.get();
            cancel.get();
            String status = jdbc.queryForObject("SELECT status FROM booking_order WHERE id = ?", String.class, id);
            assertEquals(1, wins.get());
            assertEquals(1, rejects.get());
            assertTrue("COMPLETED".equals(status) || "CANCELLED".equals(status));
        } finally {
            pool.shutdownNow();
            jdbc.update("DELETE FROM booking_order WHERE order_no = 'SHROUND4RACE'");
        }
    }

    @Test
    void ticketWithOrdersCannotChangeSpot() {
        TicketType ticket = ticketTypeMapper.selectById(1L);
        Long orders = jdbc.queryForObject(
                "SELECT COUNT(*) FROM booking_order WHERE ticket_type_id = ?", Long.class, ticket.getId());
        assertTrue(orders > 0, "1 号票种应已有订单");
        Long otherSpot = jdbc.queryForObject(
                "SELECT id FROM scenic_spot WHERE id <> ? ORDER BY id LIMIT 1", Long.class, ticket.getSpotId());
        TicketSaveDTO dto = new TicketSaveDTO();
        dto.setId(ticket.getId());
        dto.setSpotId(otherSpot);
        dto.setName(ticket.getName());
        dto.setPrice(ticket.getPrice());
        dto.setDailyStock(ticket.getDailyStock());
        dto.setStatus(ticket.getStatus());
        dto.setDescription(ticket.getDescription());
        BizException ex = assertThrows(BizException.class, () -> spotService.saveTicket(dto));
        Long spotId = jdbc.queryForObject("SELECT spot_id FROM ticket_type WHERE id = ?", Long.class, ticket.getId());
        assertEquals(ticket.getSpotId(), spotId);
        assertTrue(ex.getMessage().contains("不能改所属景点"));
    }

    private void race(CountDownLatch start, Runnable action, AtomicInteger wins, AtomicInteger rejects) {
        try {
            start.await();
            action.run();
            wins.incrementAndGet();
        } catch (BizException ex) {
            rejects.incrementAndGet();
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException(ex);
        }
    }

    private String login(String username, String password) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"username\":\"" + username + "\",\"password\":\"" + password + "\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andReturn();
        JsonNode body = objectMapper.readTree(result.getResponse().getContentAsString());
        return body.path("data").path("token").asText();
    }
}
