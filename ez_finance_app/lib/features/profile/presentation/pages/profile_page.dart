import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileBloc>().add(
        LoadProfileEvent(userId: authState.user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.isSyncing)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (!state.profile.isSynced)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.cloud_off, size: 20),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.cloud_done,
                          size: 20,
                          color: Colors.green,
                        ),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            final profile = state.profile;
            return RefreshIndicator(
              onRefresh: () async {
                _loadProfile();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        profile.fullName.isNotEmpty
                            ? profile.fullName[0].toUpperCase()
                            : '?',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.fullName.isNotEmpty
                          ? profile.fullName
                          : 'No name set',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 32),
                    _buildInfoCard(
                      context,
                      'First Name',
                      profile.firstName ?? 'Not set',
                      Icons.person_outline,
                    ),
                    _buildInfoCard(
                      context,
                      'Last Name',
                      profile.lastName ?? 'Not set',
                      Icons.person_outline,
                    ),
                    _buildInfoCard(
                      context,
                      'Phone',
                      profile.phone ?? 'Not set',
                      Icons.phone_outlined,
                    ),
                    _buildInfoCard(
                      context,
                      'Address',
                      profile.address ?? 'Not set',
                      Icons.location_on_outlined,
                    ),
                    _buildInfoCard(
                      context,
                      'Date of Birth',
                      profile.dateOfBirth != null
                          ? '${profile.dateOfBirth!.day}/${profile.dateOfBirth!.month}/${profile.dateOfBirth!.year}'
                          : 'Not set',
                      Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => context.push(RouteNames.editProfile),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('No profile data available'));
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
