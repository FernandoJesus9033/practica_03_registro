import 'package:flutter/material.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    ),
    home: const ProductosPage(),
  );
}

class Producto {
  final String nombre;
  final String categoria;
  final double precio;
  final int existencia;

  Producto({
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.existencia,
  });

  double get subtotal => precio * existencia;
}

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final formKey = GlobalKey<FormState>();
  final nombre = TextEditingController();
  final precio = TextEditingController();
  final existencia = TextEditingController();
  String categoria = 'Alimentos';

  final List<Producto> productos = [];

  final List<String> categorias = [
    'Alimentos',
    'Bebidas',
    'Limpieza',
    'Electrónica',
    'Ropa',
    'Otros',
  ];

  double get totalInventario {
    return productos.fold(0, (sum, p) => sum + p.subtotal);
  }

  void guardar() {
    if (formKey.currentState!.validate()) {
      setState(() {
        productos.add(
          Producto(
            nombre: nombre.text.trim(),
            categoria: categoria,
            precio: double.parse(precio.text),
            existencia: int.parse(existencia.text),
          ),
        );
        nombre.clear();
        precio.clear();
        existencia.clear();
        categoria = 'Alimentos';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Producto agregado'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void eliminar(int index) {
    final producto = productos[index];
    setState(() {
      productos.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗑️ ${producto.nombre} eliminado'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    nombre.dispose();
    precio.dispose();
    existencia.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de productos'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final ancho = c.maxWidth > 700 ? 600.0 : c.maxWidth;
          return Center(
            child: SizedBox(
              width: ancho,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nombre,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del producto',
                              hintText: 'Ej: Leche entera',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.inventory),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return '⚠️ Ingresa el nombre';
                              }
                              if (v.trim().length < 3) {
                                return '⚠️ Mínimo 3 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: categoria,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: categorias
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => categoria = v ?? 'Alimentos'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: precio,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Precio',
                              hintText: 'Ej: 25.50',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                              prefixText: '\$ ',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return '⚠️ Ingresa el precio';
                              }
                              final n = double.tryParse(v);
                              if (n == null) {
                                return '⚠️ Ingresa un número válido';
                              }
                              if (n <= 0) {
                                return '⚠️ El precio debe ser mayor a 0';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: existencia,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Existencia',
                              hintText: 'Ej: 10',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return '⚠️ Ingresa la existencia';
                              }
                              final n = int.tryParse(v);
                              if (n == null) {
                                return '⚠️ Ingresa un número entero';
                              }
                              if (n <= 0) {
                                return '⚠️ Debe ser mayor a 0';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: guardar,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar producto'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    Expanded(
                      child: productos.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No hay productos registrados',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: productos.length,
                              itemBuilder: (_, i) {
                                final p = productos[i];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      child: Text('${i + 1}'),
                                    ),
                                    title: Text(
                                      p.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${p.categoria} | '
                                      '\$${p.precio.toStringAsFixed(2)} | '
                                      '${p.existencia} pzas\n'
                                      'Subtotal: \$${p.subtotal.toStringAsFixed(2)}',
                                    ),
                                    isThreeLine: true,
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => eliminar(i),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calculate),
                              SizedBox(width: 8),
                              Text(
                                'Total del inventario:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$${totalInventario.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
