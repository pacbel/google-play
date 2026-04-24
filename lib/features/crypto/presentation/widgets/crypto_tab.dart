import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/crypto_cubit.dart';
import 'error_banner.dart';
import 'result_card.dart';

class CryptoTab extends StatefulWidget {
  final bool isEncrypt;

  const CryptoTab({
    super.key,
    required this.isEncrypt,
  });

  @override
  State<CryptoTab> createState() => _CryptoTabState();
}

class _CryptoTabState extends State<CryptoTab> {
  final _controller = TextEditingController();

  String get _label => widget.isEncrypt ? 'Criptografar' : 'Descriptografar';
  String get _inputLabel =>
      widget.isEncrypt ? 'Texto para criptografar' : 'Bytes para descriptografar';
  String get _inputHint => widget.isEncrypt
      ? 'Digite o texto que deseja criptografar...'
      : 'Cole os bytes criptografados aqui...';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    context.read<CryptoCubit>().clear();
  }

  void _submit() {
    final input = _controller.text;
    if (widget.isEncrypt) {
      context.read<CryptoCubit>().encrypt(input);
    } else {
      context.read<CryptoCubit>().decrypt(input);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CryptoCubit, CryptoState>(
      builder: (context, state) {
        final isLoading = state is CryptoLoading;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                enabled: !isLoading,
                maxLines: 4,
                style: const TextStyle(
                  color: Color(0xFFC0C0C0),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: _inputLabel,
                  hintText: _inputHint,
                  labelStyle: const TextStyle(color: Color(0xFFC0C0C0)),
                  hintStyle: const TextStyle(color: Color(0xFF3D4852)),
                  filled: true,
                  fillColor: const Color(0xFF1E252B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3D4852)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3D4852)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFD4AF37),
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3D4852)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF1E252B),
                        disabledBackgroundColor: const Color(0xFF3D4852),
                        disabledForegroundColor: const Color(0xFF2C343C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFD4AF37),
                              ),
                            )
                          : Text(
                              _label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: isLoading ? null : _clear,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC0C0C0),
                      side: const BorderSide(color: Color(0xFF3D4852)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Limpar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (state is CryptoSuccess) ResultCard(result: state.result),
              if (state is CryptoFailure)
                ErrorBanner(
                  message: state.message,
                  canRetry: state.canRetry,
                  onRetry: state.canRetry
                      ? () => context.read<CryptoCubit>().retry()
                      : null,
                ),
            ],
          ),
        );
      },
    );
  }
}
