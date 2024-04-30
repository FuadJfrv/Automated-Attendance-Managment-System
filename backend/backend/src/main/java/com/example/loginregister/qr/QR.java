package com.example.loginregister.qr;


import com.example.loginregister.meeting.Meeting;
import com.example.loginregister.session.Session;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class QR
{
    @SequenceGenerator(name = "course_sequence", sequenceName = "course_sequence", allocationSize = 1)
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "course_sequence")
    private Long id;
    private String data;

    public QR(String data)
    {
        this.data = data;
    }

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name ="meeting_id")
    private Meeting meeting;
}
