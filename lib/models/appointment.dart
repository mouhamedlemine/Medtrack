class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime dateTime;
  final String note;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.dateTime,
    required this.note,
  });
}