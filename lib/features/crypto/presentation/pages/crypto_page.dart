import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/crypto_remote_data_source.dart';
import '../../data/repositories/crypto_repository_impl.dart';
import '../../domain/usecases/decrypt_use_case.dart';
import '../../domain/usecases/encrypt_use_case.dart';
import '../cubit/crypto_cubit.dart';
import '../widgets/crypto_tab.dart';

class CryptoPage extends StatelessWidget {
  const CryptoPage({super.key});

  CryptoCubit _buildCubit() {
    final dio = DioClient.createDio();
    final dataSource = CryptoRemoteDataSourceImpl(dio);
    final repository = CryptoRepositoryImpl(
      dataSource: dataSource,
      connectivityService: ConnectivityServiceImpl(),
    );
    return CryptoCubit(
      encryptUseCase: EncryptUseCase(repository),
      decryptUseCase: DecryptUseCase(repository),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF2C343C),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E252B),
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFF1D592)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security,
                  color: Color(0xFF1E252B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Crypto App',
                style: TextStyle(
                  color: Color(0xFFF1D592),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: Color(0xFFD4AF37),
            unselectedLabelColor: Color(0xFFC0C0C0),
            indicatorColor: Color(0xFFD4AF37),
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
            tabs: [
              Tab(icon: Icon(Icons.lock_outline), text: 'Criptografar'),
              Tab(icon: Icon(Icons.lock_open_outlined), text: 'Descriptografar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BlocProvider(
              create: (_) => _buildCubit(),
              child: const CryptoTab(isEncrypt: true),
            ),
            BlocProvider(
              create: (_) => _buildCubit(),
              child: const CryptoTab(isEncrypt: false),
            ),
          ],
        ),
      ),
    );
  }
}
