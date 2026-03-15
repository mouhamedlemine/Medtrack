import '../models/patient.dart';
import '../models/appointment.dart';

class ClinicRepository {
  static final List<Patient> patients = [
    Patient(
      id: 'p1',
      name: 'Ahmed Mohamed',
      age: 42,
      phone: '22248123456',
      condition: 'Diabetes',
      notes: 'Needs monthly follow-up.',
    ),
    Patient(
      id: 'p2',
      name: 'Fatima Ali',
      age: 31,
      phone: '22244111222',
      condition: 'Hypertension',
      notes: 'Monitor blood pressure regularly.',
    ),
  ];

  static final List<Appointment> appointments = [
    Appointment(
      id: 'a1',
      patientId: 'p1',
      patientName: 'Ahmed Mohamed',
      dateTime: DateTime.now().add(const Duration(hours: 3)),
      note: 'Routine consultation',
    ),
    Appointment(
      id: 'a2',
      patientId: 'p2',
      patientName: 'Fatima Ali',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      note: 'Blood pressure follow-up',
    ),
  ];

  static void addPatient(Patient patient) {
    patients.add(patient);
  }

  static void addAppointment(Appointment appointment) {
    appointments.add(appointment);
  }
}