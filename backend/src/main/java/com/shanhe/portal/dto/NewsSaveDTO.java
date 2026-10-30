package com.shanhe.portal.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class NewsSaveDTO {
    private Long id;
    @NotBlank(message = "请输入标题")
    private String title;
    private String coverUrl;
    @NotBlank(message = "请输入摘要")
    private String summary;
    @NotBlank(message = "请输入正文")
    private String content;
    private Integer status;
    private LocalDateTime publishedAt;
}
