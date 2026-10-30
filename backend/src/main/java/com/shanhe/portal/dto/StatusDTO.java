package com.shanhe.portal.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class StatusDTO {
    @NotBlank(message = "请选择状态")
    private String status;
}
