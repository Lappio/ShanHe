package com.shanhe.portal.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class TicketSaveDTO {
    private Long id;
    @NotNull(message = "请选择景点")
    private Long spotId;
    @NotBlank(message = "请输入票种名称")
    @Size(max = 60, message = "票种名称不超过 60 字")
    private String name;
    @NotNull(message = "请输入价格")
    @Min(value = 0, message = "价格不能为负")
    private BigDecimal price;
    private String description;
    @NotNull(message = "请输入每日库存")
    @Min(value = 0, message = "库存不能为负")
    private Integer dailyStock;
    private Integer status;
}
