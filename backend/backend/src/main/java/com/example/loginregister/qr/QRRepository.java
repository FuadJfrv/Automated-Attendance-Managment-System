package com.example.loginregister.qr;

import com.example.loginregister.meeting.Meeting;
import com.example.loginregister.session.Session;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.HashSet;
import java.util.List;
import java.util.Optional;

@Repository
public interface QRRepository  extends JpaRepository<QR, Long>
{
    List<QR> findByDataAndMeeting(String data, Meeting meeting);
}
