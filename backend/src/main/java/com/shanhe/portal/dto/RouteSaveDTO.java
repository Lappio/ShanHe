package com.shanhe.portal.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class RouteSaveDTO {
    private Long id;
    @NotBlank(message = "请输入路线标题")
    @Size(max = 80, message = "标题过长")
    private String title;
    @NotNull(message = "请输入天数")
    @Min(value = 1, message = "天数至少为 1")
    @Max(value = 30, message = "天数过多")
    private Integer days;
    private String coverUrl;
    @NotBlank(message = "请输入摘要")
    @Size(max = 500, message = "摘要不超过 500 字")
    private String summary;
    private String detail;
    private BigDecimal priceFrom;
    private Integer status;
    @Valid
    @NotEmpty(message = "请至少添加一个景点")
    private List<StopItem> stops;

    @Data
    public static class StopItem {
        @NotNull(message = "请选择景点")
        private Long spotId;
        @NotNull(message = "请填写第几天")
        @Min(1)
        private Integer dayNo;
        private Integer sortOrder;
        private String stayNote;
    }
}
