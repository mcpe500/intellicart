import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicart/domain/entities/user.dart';
import 'package:intellicart/domain/usecases/get_current_user.dart';
import 'package:intellicart/domain/usecases/sign_out.dart';
import 'package:intellicart/domain/usecases/update_user.dart';
import 'package:intellicart/presentation/bloc/user/user_bloc.dart';
import 'package:intellicart/presentation/bloc/user/user_event.dart';
import 'package:intellicart/presentation/bloc/user/user_state.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([
  GetCurrentUser,
  UpdateUser,
  SignOut,
])
import 'user_bloc_test.mocks.dart';

void main() {
  group('UserBloc', () {
    late MockGetCurrentUser mockGetCurrentUser;
    late MockUpdateUser mockUpdateUser;
    late MockSignOut mockSignOut;
    late UserBloc userBloc;

    setUp(() {
      mockGetCurrentUser = MockGetCurrentUser();
      mockUpdateUser = MockUpdateUser();
      mockSignOut = MockSignOut();
      userBloc = UserBloc(
        getCurrentUser: mockGetCurrentUser,
        updateUser: mockUpdateUser,
        signOut: mockSignOut,
      );
    });

    tearDown(() {
      userBloc.close();
    });

    test('initial state is UserInitial', () {
      expect(userBloc.state, equals(UserInitial()));
    });

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserLoaded] when LoadUser is added',
      build: () {
        when(mockGetCurrentUser()).thenAnswer(
          (_) async => User(
            id: 1,
            email: 'test@example.com',
            name: 'Test User',
          ),
        );
        return userBloc;
      },
      act: (bloc) => bloc.add(LoadUser()),
      expect: () => [
        UserLoading(),
        const UserLoaded(
          User(
            id: 1,
            email: 'test@example.com',
            name: 'Test User',
          ),
        ),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserUnauthenticated] when LoadUser fails',
      build: () {
        when(mockGetCurrentUser()).thenThrow(Exception('Failed to load user'));
        return userBloc;
      },
      act: (bloc) => bloc.add(LoadUser()),
      expect: () => [
        UserLoading(),
        UserUnauthenticated(),
      ],
    );
  });
}