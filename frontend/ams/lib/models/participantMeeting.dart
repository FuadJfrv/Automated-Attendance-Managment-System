enum ParticipantMeetingStatus {
  present,
  late,
  absent;

  static ParticipantMeetingStatus fromString(String statusString) {
  return ParticipantMeetingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == statusString.toLowerCase(),
    orElse: () => throw Exception('Invalid status value: $statusString'),
  );
}
}


class ParticipantMeeting {
  DateTime startTime;
  DateTime endTime;
  //bool hasParticipated;
  ParticipantMeetingStatus status;
  String participantName;

  ParticipantMeeting(this.startTime, this.endTime, this.status, {this.participantName = ""});

}