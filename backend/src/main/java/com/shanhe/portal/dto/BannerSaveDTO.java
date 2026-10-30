package com.shanhe.portal.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class BannerSaveDTO {
    private Long id;
    @NotBlank(message = "请输入标题")
    private String title;
    private String subtitle;
    @NotBlank(message = "请输入图片地址")
    private String imageUrl;
    private String linkUrl;
    private Integer sortOrder;
    private Integer status;
}
