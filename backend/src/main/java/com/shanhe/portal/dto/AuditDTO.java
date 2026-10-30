package com.shanhe.portal.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AuditDTO {
    @NotBlank(message = "请选择审核结果")
    private String status;
    private String rejectReason;
}
