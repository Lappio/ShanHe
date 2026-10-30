package com.shanhe.portal.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class NoteSaveDTO {
    @NotBlank(message = "请输入标题")
    @Size(max = 120, message = "标题不超过 120 字")
    private String title;
    @NotBlank(message = "请输入正文")
    @Size(min = 20, max = 8000, message = "正文长度为 20-8000 字")
    private String content;
    private String coverUrl;
    private Long spotId;
}
