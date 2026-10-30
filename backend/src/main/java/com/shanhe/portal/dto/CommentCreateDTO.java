package com.shanhe.portal.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CommentCreateDTO {
    @NotBlank(message = "缺少评论目标")
    private String targetType;
    @NotNull(message = "缺少评论目标")
    private Long targetId;
    @NotBlank(message = "请输入评论")
    @Size(max = 500, message = "评论不超过 500 字")
    private String content;
}
