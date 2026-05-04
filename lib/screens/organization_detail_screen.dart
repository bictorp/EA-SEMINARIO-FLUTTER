import 'package:flutter/material.dart';
import '../models/organization.dart';
import '../models/task.dart';
import '../services/organization_service.dart';
import 'create_task_screen.dart';
import 'task_detail_screen.dart';

class OrganizationDetailScreen extends StatefulWidget {
  final Organization organization;

  const OrganizationDetailScreen({super.key, required this.organization});

  @override
  State<OrganizationDetailScreen> createState() =>
      _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  final OrganizationService _organizationService = OrganizationService();
  late Future<List<Task>> _tasksFuture;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _tasksFuture = _organizationService.fetchTasksByOrganization(
      widget.organization.id,
    );
  }

  void _reloadTasks() {
    setState(() {
      _tasksFuture = _organizationService.fetchTasksByOrganization(
        widget.organization.id,
      );
    });
  }

  // Ejercicio Flutter
  /// Cambia el estado de una tarea localmente.
  void _changeTaskStatus(Task task, TaskStatus newStatus) {
    setState(() {
      task.estado = newStatus;
    });
  }

  /// Filtra tareas por estado.
  List<Task> _filterByStatus(TaskStatus status) {
    return _tasks.where((task) => task.estado == status).toList();
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  // Ejercicio Flutter
  /// Devuelve el color asociado a cada estado.
  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return const Color(0xFF6C63FF); // Violeta
      case TaskStatus.inProgress:
        return const Color(0xFFFFA726); // Naranja
      case TaskStatus.done:
        return const Color(0xFF66BB6A); // Verde
    }
  }

  /// Devuelve el icono asociado a cada estado.
  IconData _statusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.timelapse;
      case TaskStatus.done:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(widget.organization.name),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Ejercicio Flutter
          // Cabecera de la organización
          _buildHeader(),
          const SizedBox(height: 12),
          // Tablero Kanban
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: _tasksFuture,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'No se pudieron cargar las tareas. ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    _tasks = snapshot.data ?? <Task>[];

                    if (_tasks.isEmpty) {
                      return const Center(
                        child: Text('Aún no hay tareas en esta organización'),
                      );
                    }

                    return _buildKanbanBoard();
                  },
            ),
          ),
          _buildCreateButton(context),
        ],
      ),
    );
  }

  // Ejercicio Flutter
  /// Cabecera con info de la organización.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.business, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.organization.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${widget.organization.id}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tablero Kanban con 3 columnas deslizables horizontalmente.
  Widget _buildKanbanBoard() {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: TaskStatus.values.map((status) {
        final tasksForStatus = _filterByStatus(status);
        return _buildKanbanColumn(status, tasksForStatus);
      }).toList(),
    );
  }

  /// Columna individual del Kanban.
  Widget _buildKanbanColumn(TaskStatus status, List<Task> tasks) {
    final Color color = _statusColor(status);
    // Ancho de cada columna: 85% del ancho de la pantalla para que se vea parte de la siguiente
    final double columnWidth = MediaQuery.of(context).size.width * 0.85;

    return Container(
      width: columnWidth,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Encabezado de columna
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(_statusIcon(status), color: color, size: 22),
                const SizedBox(width: 10),
                Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lista de tareas dentro de la columna
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No hay tareas',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(tasks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta individual de tarea dentro de una columna.
  Widget _buildTaskCard(Task task) {
    final Color color = _statusColor(task.estado);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la tarea
            Text(
              task.titulo,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Fechas
            Row(
              children: [
                Icon(Icons.calendar_today, size: 13, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(task.fechaInicio)} → ${_formatDate(task.fechaFin)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Usuarios asignados (avatares)
            if (task.usuarios.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.people_outline, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      task.usuarios.map((u) => u.name).join(', '),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            // Selector de estado
            _buildStatusChips(task),
          ],
        ),
      ),
    );
  }

  /// Chips para cambiar el estado de la tarea directamente.
  Widget _buildStatusChips(Task task) {
    return Wrap(
      spacing: 6,
      children: TaskStatus.values.map((status) {
        final bool isSelected = task.estado == status;
        final Color color = _statusColor(status);

        return GestureDetector(
          onTap: () {
            if (!isSelected) {
              _changeTaskStatus(task, status);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _statusIcon(status),
                  size: 13,
                  color: isSelected ? color : Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? color : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () async {
            final bool? created = await Navigator.of(context).push<bool>(
              MaterialPageRoute<bool>(
                builder: (BuildContext context) => CreateTaskScreen(
                  organizacionId: widget.organization.id,
                  usuarios: widget.organization.usuarios,
                ),
              ),
            );

            if (created == true) {
              _reloadTasks();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_task),
              SizedBox(width: 10),
              Text(
                'Crear tarea',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
