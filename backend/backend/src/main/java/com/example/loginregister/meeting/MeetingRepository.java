package com.example.loginregister.meeting;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface MeetingRepository extends JpaRepository<Meeting, Long>
{
    List<Meeting> findByOngoingTrueAndSessionId(Long sessionId);

}
