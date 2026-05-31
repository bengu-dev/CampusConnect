package com.campusconnect.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CafeteriaMenuDto implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long              id;
    private String            menuDate;   // "yyyy-MM-dd"
    private String            mealType;   // BREAKFAST, LUNCH, DINNER
    private List<CafeteriaItemDto> items;
    private Integer           totalCalories;
    private BigDecimal        price;
}
