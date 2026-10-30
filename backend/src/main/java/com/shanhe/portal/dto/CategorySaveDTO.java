package com.shanhe.portal.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CategorySaveDTO {
    private Long id;
    @NotBlank(message = "请输入分类名称")
    @Size(max = 40, message = "分类名称过长")
    private String name;
    private String description;
    private String icon;
    private Integer sortOrder;
}
