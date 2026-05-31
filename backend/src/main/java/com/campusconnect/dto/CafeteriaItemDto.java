package com.campusconnect.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import java.io.Serializable;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CafeteriaItemDto implements Serializable {
    private static final long serialVersionUID = 1L;
    private String name;
    private Integer calories;
}
