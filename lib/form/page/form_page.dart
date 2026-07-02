import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nomorPolisiController = TextEditingController();
  final TextEditingController kilometerController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  String? selectedKondisiEksterior;
  String? selectedKondisiMesin;

  final List<String> imagesKendaraan = [];
  final List<String> imagesSpedometer = [];

  final ImagePicker imagePicker = ImagePicker();

  final List<String> kondisiEkterior = [
    'Baik',
    'Lecet Ringan',
    'Rusak',
    'Sangat Rusak',
  ];

  final List<String> kondisiMesin = [
    'Hidup Normal',
    'Hidup Tidak Normal',
    'Mati',
  ];

  Future<void> _pickImage({
    required List<String> images,
    required int maxImage,
    required String title,
  }) async {
    if (images.length >= maxImage) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Maksimal $maxImage foto $title')));
      return;
    }

    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.camera,
    );

    if (image == null) return;

    setState(() {
      images.add(image.path);
    });
  }

  Future<void> _showPreviewDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nomor Polisi : ${nomorPolisiController.text}'),
                Text('Kilometer : ${kilometerController.text}'),
                Text('Catatan : ${catatanController.text}'),
                Text('Foto Kendaraan : '),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: imagesKendaraan.map((path) {
                    return Image.file(
                      File(path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
                Text('Foto Spedometer :'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: imagesSpedometer.map((path) {
                    return Image.file(
                      File(path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  // Reset Form
                  formKey.currentState?.reset();

                  // Clear TextField
                  nomorPolisiController.clear();
                  kilometerController.clear();
                  catatanController.clear();

                  // Reset Dropdown
                  selectedKondisiEksterior = null;
                  selectedKondisiMesin = null;

                  // Reset Foto
                  imagesKendaraan.clear();
                  imagesSpedometer.clear();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data berhasil disubmit')),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Page')),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                TextFormField(
                  controller: nomorPolisiController,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Polisi',
                    hintText: 'Contoh: B 1234 ABC',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor Polisi tidak boleh kosong';
                    }

                    if (!RegExp(
                      r'^[A-Z]{1,2}\s\d{1,4}\s[A-Z]{1,3}$',
                    ).hasMatch(value)) {
                      return 'Format Nomor Polisi tidak valid';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: kilometerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Kilometer',
                    hintText: 'Masukkan Kilometer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kilometer tidak boleh kosong';
                    }
                    if (int.tryParse(value) == 0 || int.parse(value) < 0) {
                      return 'Kilometer harus berupa angka';
                    }
                    return null;
                  },
                ),

                const Text('Foto Kendaraan'),
                if (imagesKendaraan.isEmpty || imagesKendaraan.length < 4)
                  FormField<List<String>>(
                    initialValue: imagesKendaraan,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Foto kendaraan wajib diisi';
                      }
                      return null;
                    },
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: imagesKendaraan.isEmpty
                                  ? ''
                                  : '${imagesKendaraan.length} foto dipilih',
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Foto Kendaraan',
                              suffixIcon: Icon(Icons.camera_alt),
                              border: OutlineInputBorder(),
                            ),
                            onTap: () async {
                              await _pickImage(
                                images: imagesKendaraan,
                                maxImage: 4,
                                title: 'kendaraan',
                              );

                              state.didChange(imagesKendaraan);
                            },
                          ),

                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                state.errorText!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                if (imagesKendaraan.isNotEmpty) ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: imagesKendaraan.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          File(imagesKendaraan[index]),
                        ),
                      );
                    },
                  ),
                ],
                Text('Foto Spedometer'),
                if (imagesSpedometer.isEmpty) ...[
                  FormField<List<String>>(
                    initialValue: imagesSpedometer,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Foto spedometer wajib diisi';
                      }
                      return null;
                    },
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: imagesSpedometer.isEmpty
                                  ? ''
                                  : '${imagesSpedometer.length} foto dipilih',
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Foto Spedometer',
                              suffixIcon: Icon(Icons.camera_alt),
                              border: OutlineInputBorder(),
                            ),
                            onTap: () async {
                              await _pickImage(
                                images: imagesSpedometer,
                                maxImage: 1,
                                title: 'spedometer',
                              );

                              state.didChange(imagesSpedometer);
                            },
                          ),

                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                state.errorText!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
                if (imagesSpedometer.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: imagesSpedometer.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          File(imagesSpedometer[index]),
                        ),
                      );
                    },
                  ),
                DropdownButtonFormField<String>(
                  value: selectedKondisiEksterior,
                  decoration: const InputDecoration(
                    labelText: 'Kondisi Eksterior',
                    border: OutlineInputBorder(),
                  ),
                  items: kondisiEkterior.map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedKondisiEksterior = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Pilih kondisi eksterior';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedKondisiMesin,
                  decoration: const InputDecoration(
                    labelText: 'Kondisi Mesin',
                    border: OutlineInputBorder(),
                  ),
                  items: kondisiMesin.map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedKondisiMesin = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Pilih kondisi mesin';
                    }
                    return null;
                  },
                ),

                TextFormField(
                  controller: catatanController,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan',
                    hintText: 'Masukkan keterangan tambahan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  maxLines: 3,
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;

                      _showPreviewDialog();
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
