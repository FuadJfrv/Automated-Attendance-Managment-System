package com.example.loginregister.session;

import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.ToString;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
@EqualsAndHashCode
@ToString
public class ScheduledSessionRequest
{
    private String name;

    private BigDecimal sessionDuration;
    private BigDecimal lateAfterDuration;
    private BigDecimal absentAfterDuration;

    private LocalDateTime scheduledStartTime;
    private LocalDate scheduledStartDay;

    private boolean oneTime;
    private boolean daily;
    private int dayIndex;
    private boolean weekly;
    private int weekIndex;

    private Boolean onMonday;
    private Boolean onTuesday;
    private Boolean onWednesday;
    private Boolean onThursday;
    private Boolean onFriday;
    private Boolean onSaturday;
    private Boolean onSunday;
}
