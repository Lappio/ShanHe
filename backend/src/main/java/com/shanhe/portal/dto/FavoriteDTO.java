package com.shanhe.portal.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class FavoriteDTO {
    @NotBlank(message = "缺少收藏类型")
    private String targetType;
    @NotNull(message = "缺少收藏目标")
    private Long targetId;
}
