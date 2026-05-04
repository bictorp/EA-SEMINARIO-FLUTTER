import 'organization.dart';

// Ejercicio Flutter
/// Los posibles estados de una tarea (tipo Kanban).
enum TaskStatus {
  todo('To do'),
  inProgress('In progress'),
  done('Done');

  final String label;
  const TaskStatus(this.label);

  /// Convierte un string proveniente del backend (o almacenamiento local) al enum.
  static TaskStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'in progress':
      case 'inprogress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      case 'to do':
      case 'todo':
      case 'to_do':
      default:
        return TaskStatus.todo;
    }
  }
}

class Task {
  final String id;
  final String titulo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final List<OrganizationUser> usuarios;
  TaskStatus estado;

  Task({
    required this.id,
    required this.titulo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.usuarios,
    this.estado = TaskStatus.todo,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final String id = (json['_id'] ?? json['id'] ?? '').toString();
    final String titulo = (json['titulo'] ?? json['title'] ?? 'Sin título')
        .toString();

    return Task(
      id: id,
      titulo: titulo,
      fechaInicio: _parseDate(json['fechaInicio'] ?? json['fecha_inicio']),
      fechaFin: _parseDate(json['fechaFin'] ?? json['fecha_fin']),
      usuarios:
          (json['usuarios'] as List<dynamic>?)
              ?.map((dynamic u) => OrganizationUser.fromJson(u))
              .toList() ??
          [],
      estado: TaskStatus.fromString(json['estado']?.toString()),
    );
  }
  // Ejercicio Flutter
  /// Crea una copia de la tarea con un estado diferente.
  Task copyWith({TaskStatus? estado}) {
    return Task(
      id: id,
      titulo: titulo,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      usuarios: usuarios,
      estado: estado ?? this.estado,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String) {
      final DateTime? parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    throw FormatException('Fecha inválida en Task: $value');
  }
}
