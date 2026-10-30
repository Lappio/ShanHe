package com.shanhe.portal.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

import java.time.LocalDate;

@Data
public class OrderCreateDTO {
    @NotNull(message = "请选择景点")
    private Long spotId;
    @NotNull(message = "请选择票种")
    private Long ticketTypeId;
    @NotNull(message = "请选择游玩日期")
    private LocalDate visitDate;
    @NotNull(message = "请填写数量")
    @Min(value = 1, message = "至少预约 1 张")
    @Max(value = 6, message = "单笔最多 6 张")
    private Integer quantity;
    @NotBlank(message = "请填写联系人")
    private String contactName;
    @NotBlank(message = "请填写手机号")
    @Pattern(regexp = "^1\\d{10}$", message = "手机号格式不正确")
    private String contactPhone;
}
