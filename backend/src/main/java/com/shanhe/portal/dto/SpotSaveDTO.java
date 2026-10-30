package com.shanhe.portal.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class SpotSaveDTO {
    private Long id;
    @NotNull(message = "请选择分类")
    private Long categoryId;
    @NotBlank(message = "请输入景点名称")
    @Size(max = 80, message = "名称过长")
    private String name;
    @NotBlank(message = "请输入省份")
    private String province;
    @NotBlank(message = "请输入城市")
    private String city;
    @NotBlank(message = "请输入地址")
    private String address;
    private BigDecimal longitude;
    private BigDecimal latitude;
    private String openTime;
    @NotBlank(message = "请输入简介")
    @Size(max = 500, message = "简介不超过 500 字")
    private String summary;
    private String detail;
    private String coverUrl;
    private String videoUrl;
    private String videoCredit;
    private BigDecimal priceFrom;
    private BigDecimal rating;
    private Integer status;
    @Valid
    private List<ImageItem> images;

    @Data
    public static class ImageItem {
        @NotBlank(message = "图片地址不能为空")
        private String url;
        private String caption;
        private String credit;
        private Integer sortOrder;
    }
}
