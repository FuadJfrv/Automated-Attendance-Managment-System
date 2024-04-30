package com.example.loginregister.session;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@AllArgsConstructor
public class GeofenceDTO
{
    private BigDecimal longitude;
    private BigDecimal latitude;
    private BigDecimal radius;
}
