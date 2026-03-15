import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/clinic_repository.dart';
import '../models/appointment.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allAppointments = [...ClinicRepository.appointments]
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final filteredAppointments = allAppointments.where((appointment) {
      final query = _searchQuery.toLowerCase().trim();

      final matchesSearch = query.isEmpty ||
          appointment.patientName.toLowerCase().contains(query) ||
          appointment.note.toLowerCase().contains(query);

      final now = DateTime.now();
      final appointmentDate = appointment.dateTime;

      bool matchesFilter = true;
      if (_selectedFilter == 'Today') {
        matchesFilter = appointmentDate.year == now.year &&
            appointmentDate.month == now.month &&
            appointmentDate.day == now.day;
      } else if (_selectedFilter == 'Upcoming') {
        matchesFilter = appointmentDate.isAfter(now);
      } else if (_selectedFilter == 'Past') {
        matchesFilter = appointmentDate.isBefore(now);
      }

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            final maxWidth = isMobile ? double.infinity : 1100.0;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AppointmentsTopBar(
                        isMobile: isMobile,
                        totalAppointments: filteredAppointments.length,
                      ),
                      const SizedBox(height: 24),
                      _AppointmentsHeaderBanner(
                        isMobile: isMobile,
                        totalAppointments: filteredAppointments.length,
                      ),
                      const SizedBox(height: 24),
                      _AppointmentsToolbar(
                        isMobile: isMobile,
                        controller: _searchController,
                        selectedFilter: _selectedFilter,
                        onSearchChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        onFilterChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedFilter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      if (filteredAppointments.isEmpty)
                        const _EmptyAppointmentsState()
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredAppointments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final appointment = filteredAppointments[index];
                            return _AppointmentCard(appointment: appointment);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppointmentsTopBar extends StatelessWidget {
  final bool isMobile;
  final int totalAppointments;

  const _AppointmentsTopBar({
    required this.isMobile,
    required this.totalAppointments,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appointments',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalAppointments scheduled appointments',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppointmentsHeaderBanner extends StatelessWidget {
  final bool isMobile;
  final int totalAppointments;

  const _AppointmentsHeaderBanner({
    required this.isMobile,
    required this.totalAppointments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F766E),
            Color(0xFF115E59),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Appointment Schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track all patient visits in a clean and organized schedule.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _AppointmentBannerChip(
                  icon: Icons.event_available_rounded,
                  label: '$totalAppointments Appointments',
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Appointment Schedule',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Review, search, and manage all clinic appointments with a professional dashboard.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _AppointmentBannerChip(
                  icon: Icons.event_available_rounded,
                  label: '$totalAppointments Appointments',
                ),
              ],
            ),
    );
  }
}

class _AppointmentBannerChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AppointmentBannerChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentsToolbar extends StatelessWidget {
  final bool isMobile;
  final TextEditingController controller;
  final String selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onFilterChanged;

  const _AppointmentsToolbar({
    required this.isMobile,
    required this.controller,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Today', 'Upcoming', 'Past'];

    if (isMobile) {
      return Column(
        children: [
          _AppointmentSearchBox(
            controller: controller,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 14),
          _AppointmentFilterDropdown(
            selectedFilter: selectedFilter,
            filters: filters,
            onChanged: onFilterChanged,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _AppointmentSearchBox(
            controller: controller,
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _AppointmentFilterDropdown(
            selectedFilter: selectedFilter,
            filters: filters,
            onChanged: onFilterChanged,
          ),
        ),
      ],
    );
  }
}

class _AppointmentSearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _AppointmentSearchBox({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Search by patient name or appointment note',
          hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Color(0xFF6B7280),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

class _AppointmentFilterDropdown extends StatelessWidget {
  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String?> onChanged;

  const _AppointmentFilterDropdown({
    required this.selectedFilter,
    required this.filters,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFilter,
          isExpanded: true,
          borderRadius: BorderRadius.circular(16),
          items: filters.map((filter) {
            return DropdownMenuItem<String>(
              value: filter,
              child: Text(filter),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEE, MMM d, yyyy • hh:mm a');
    final isPast = appointment.dateTime.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPast
                    ? [
                        const Color(0xFFE5E7EB),
                        const Color(0xFFD1D5DB),
                      ]
                    : [
                        const Color(0xFF99F6E4),
                        const Color(0xFF5EEAD4),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              size: 30,
              color: isPast
                  ? const Color(0xFF6B7280)
                  : const Color(0xFF134E4A),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    Text(
                      appointment.patientName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isPast
                            ? const Color(0xFFF3F4F6)
                            : const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isPast
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFFCCFBF1),
                        ),
                      ),
                      child: Text(
                        isPast ? 'Past' : 'Upcoming',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isPast
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF0F766E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _AppointmentInfoChip(
                  icon: Icons.schedule_rounded,
                  label: formatter.format(appointment.dateTime),
                ),
                const SizedBox(height: 14),
                _AppointmentInfoRow(
                  title: 'Appointment Note',
                  value: appointment.note,
                  icon: Icons.notes_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AppointmentInfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCCFBF1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF0F766E),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF134E4A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentInfoRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _AppointmentInfoRow({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF374151),
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyAppointmentsState extends StatelessWidget {
  const _EmptyAppointmentsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 38,
              color: Color(0xFF0F766E),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No appointments found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search or filter, or create a new appointment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}