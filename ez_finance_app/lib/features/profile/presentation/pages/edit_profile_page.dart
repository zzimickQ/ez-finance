import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _dateOfBirth;

  Profile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      _currentProfile = profileState.profile;
      _firstNameController.text = profileState.profile.firstName ?? '';
      _lastNameController.text = profileState.profile.lastName ?? '';
      _phoneController.text = profileState.profile.phone ?? '';
      _addressController.text = profileState.profile.address ?? '';
      _dateOfBirth = profileState.profile.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;

      final updatedProfile = Profile(
        id: _currentProfile?.id ?? 0,
        userId: authState.user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        dateOfBirth: _dateOfBirth,
        createdAt: _currentProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        version: (_currentProfile?.version ?? 0) + 1,
        isSynced: false,
      );

      if (_currentProfile == null) {
        context.read<ProfileBloc>().add(
          CreateProfileEvent(profile: updatedProfile),
        );
      } else {
        context.read<ProfileBloc>().add(
          UpdateProfileEvent(profile: updatedProfile),
        );
      }
    }
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [TextButton(onPressed: _onSave, child: const Text('Save'))],
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
            context.pop();
          } else if (state is ProfileLoaded && _currentProfile == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile created successfully')),
            );
            context.pop();
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDateOfBirth,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dateOfBirth != null
                              ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                              : 'Select date',
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    final isLoading = state is ProfileLoaded && state.isSyncing;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _onSave,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Changes'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
