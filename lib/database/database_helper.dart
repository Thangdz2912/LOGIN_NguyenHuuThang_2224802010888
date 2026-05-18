import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../models/answer_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quiz_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 7, 
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        fullName TEXT NOT NULL,
        email TEXT,
        age INTEGER,
        role TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        option1 TEXT NOT NULL,
        option2 TEXT NOT NULL,
        option3 TEXT NOT NULL,
        option4 TEXT NOT NULL,
        correctAnswerIndex INTEGER NOT NULL,
        explanation TEXT NOT NULL,
        createdBy INTEGER NOT NULL,
        FOREIGN KEY (createdBy) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_attempts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        score INTEGER NOT NULL,
        totalQuestions INTEGER NOT NULL,
        timeTaken INTEGER DEFAULT 0,
        completedAt TEXT NOT NULL,
        quizId INTEGER,
        FOREIGN KEY (studentId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE answer_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        attemptId INTEGER NOT NULL,
        questionId INTEGER NOT NULL,
        selectedAnswer INTEGER NOT NULL,
        isCorrect INTEGER NOT NULL,
        FOREIGN KEY (attemptId) REFERENCES quiz_attempts (id),
        FOREIGN KEY (questionId) REFERENCES questions (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE difficult_questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        questionId INTEGER NOT NULL,
        UNIQUE(studentId, questionId),
        FOREIGN KEY (studentId) REFERENCES users (id),
        FOREIGN KEY (questionId) REFERENCES questions (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        badgeCode TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_achievements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        achievementId INTEGER NOT NULL,
        awardedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (achievementId) REFERENCES achievements (id)
      )
    ''');

    // New Tables for Version 7
    await db.execute('''
      CREATE TABLE classrooms(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT UNIQUE NOT NULL,
        teacherId INTEGER NOT NULL,
        FOREIGN KEY (teacherId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE quizzes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        classCode TEXT NOT NULL,
        startTime TEXT,
        endTime TEXT,
        teacherId INTEGER NOT NULL,
        FOREIGN KEY (teacherId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_questions_link(
        quizId INTEGER NOT NULL,
        questionId INTEGER NOT NULL,
        PRIMARY KEY (quizId, questionId),
        FOREIGN KEY (quizId) REFERENCES quizzes (id),
        FOREIGN KEY (questionId) REFERENCES questions (id)
      )
    ''');

    await _insertDefaultData(db);
    await _insertDefaultAchievements(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 7) {
       await db.execute('DROP TABLE IF EXISTS quiz_questions_link');
       await db.execute('DROP TABLE IF EXISTS quizzes');
       await db.execute('DROP TABLE IF EXISTS classrooms');
       
       if (oldVersion < 6) {
         await db.execute('DROP TABLE IF EXISTS user_achievements');
         await db.execute('DROP TABLE IF EXISTS achievements');
         await db.execute('DROP TABLE IF EXISTS difficult_questions');
         await db.execute('DROP TABLE IF EXISTS answer_records');
         await db.execute('DROP TABLE IF EXISTS quiz_attempts');
         await db.execute('DROP TABLE IF EXISTS questions');
         await db.execute('DROP TABLE IF EXISTS users');
         await _createDB(db, newVersion);
       } else {
         await db.execute('''
          CREATE TABLE classrooms(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            code TEXT UNIQUE NOT NULL,
            teacherId INTEGER NOT NULL,
            FOREIGN KEY (teacherId) REFERENCES users (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE quizzes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            classCode TEXT NOT NULL,
            startTime TEXT,
            endTime TEXT,
            teacherId INTEGER NOT NULL,
            FOREIGN KEY (teacherId) REFERENCES users (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE quiz_questions_link(
            quizId INTEGER NOT NULL,
            questionId INTEGER NOT NULL,
            PRIMARY KEY (quizId, questionId),
            FOREIGN KEY (quizId) REFERENCES quizzes (id),
            FOREIGN KEY (questionId) REFERENCES questions (id)
          )
        ''');
       }
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    await db.insert('users', {
      'username': 'teacher1',
      'password': '123456',
      'fullName': 'Giáo viên Nguyễn Văn A',
      'email': 'teacher1@example.com',
      'age': 35,
      'role': 'teacher',
    });

    await db.insert('users', {
      'username': 'student1',
      'password': '123456',
      'fullName': 'Học sinh Trần Văn B',
      'email': 'student1@example.com',
      'age': 20,
      'role': 'student',
    });

    await db.insert('questions', {
      'text': 'Thủ đô của Việt Nam là gì?',
      'option1': 'Hà Nội',
      'option2': 'TP. Hồ Chí Minh',
      'option3': 'Đà Nẵng',
      'option4': 'Hải Phòng',
      'correctAnswerIndex': 0,
      'explanation': 'Hà Nội là thủ đô của Việt Nam',
      'createdBy': 1,
    });
  }

  Future<void> _insertDefaultAchievements(Database db) async {
    final achievements = [
      {'name': 'Người mới bắt đầu', 'description': 'Hoàn thành bài kiểm tra đầu tiên', 'badgeCode': 'FIRST_QUIZ'},
      {'name': 'Siêu trí tuệ', 'description': 'Đạt điểm tuyệt đối trong một bài thi', 'badgeCode': 'PERFECT_SCORE'},
      {'name': 'Thánh tốc độ', 'description': 'Hoàn thành bài thi dưới 30 giây', 'badgeCode': 'FAST_LEARNER'},
      {'name': 'Chăm chỉ', 'description': 'Làm đúng tổng cộng 100 câu hỏi', 'badgeCode': 'HARD_WORKING'},
    ];
    for (var a in achievements) {
      await db.insert('achievements', a);
    }
  }

  // ==================== USER OPERATIONS ====================

  Future<bool> register(User user) async {
    final db = await database;
    try {
      await db.insert('users', user.toMap());
      return true;
    } catch (e) {
      return false; // Thường là do trùng username (UNIQUE constraint)
    }
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<User?> login(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<int> addUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== QUESTION OPERATIONS ====================

  Future<List<Question>> getAllQuestions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('questions', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }

  Future<int> addQuestion(Question question) async {
    final db = await database;
    return await db.insert('questions', question.toMap());
  }

  Future<int> updateQuestion(Question question) async {
    final db = await database;
    return await db.update('questions', question.toMap(), where: 'id = ?', whereArgs: [question.id]);
  }

  Future<int> deleteQuestion(int id) async {
    final db = await database;
    return await db.delete('questions', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== CLASSROOM & QUIZ OPERATIONS ====================

  Future<int> addClassroom(String name, String code, int teacherId) async {
    final db = await database;
    return await db.insert('classrooms', {'name': name, 'code': code, 'teacherId': teacherId});
  }

  Future<List<Map<String, dynamic>>> getTeacherClassrooms(int teacherId) async {
    final db = await database;
    return await db.query('classrooms', where: 'teacherId = ?', whereArgs: [teacherId]);
  }

  Future<int> addScheduledQuiz(String title, String classCode, DateTime? start, DateTime? end, int teacherId, List<int> questionIds) async {
    final db = await database;
    return await db.transaction((txn) async {
      final quizId = await txn.insert('quizzes', {
        'title': title,
        'classCode': classCode,
        'startTime': start?.toIso8601String(),
        'endTime': end?.toIso8601String(),
        'teacherId': teacherId,
      });
      for (var qId in questionIds) {
        await txn.insert('quiz_questions_link', {'quizId': quizId, 'questionId': qId});
      }
      return quizId;
    });
  }

  Future<List<Map<String, dynamic>>> getQuizzesByClass(String classCode) async {
    final db = await database;
    return await db.query('quizzes', where: 'classCode = ?', whereArgs: [classCode]);
  }

  Future<List<Question>> getQuestionsForQuiz(int quizId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT q.* FROM questions q
      JOIN quiz_questions_link qql ON q.id = qql.questionId
      WHERE qql.quizId = ?
    ''', [quizId]);
    return maps.map((e) => Question.fromMap(e)).toList();
  }

  // ==================== ANALYTICS ====================

  Future<List<Map<String, dynamic>>> getMostMissedQuestions(int teacherId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT q.text, COUNT(ar.id) as missCount
      FROM answer_records ar
      JOIN questions q ON ar.questionId = q.id
      WHERE ar.isCorrect = 0 AND q.createdBy = ?
      GROUP BY q.id
      ORDER BY missCount DESC
      LIMIT 5
    ''', [teacherId]);
  }

  Future<List<Map<String, dynamic>>> getScoreDistribution(int teacherId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        CASE 
          WHEN (CAST(score AS FLOAT) / totalQuestions) * 100 <= 25 THEN '0-25%'
          WHEN (CAST(score AS FLOAT) / totalQuestions) * 100 <= 50 THEN '26-50%'
          WHEN (CAST(score AS FLOAT) / totalQuestions) * 100 <= 75 THEN '51-75%'
          ELSE '76-100%'
        END as range,
        COUNT(*) as count
      FROM quiz_attempts qa
      JOIN users u ON qa.studentId = u.id
      GROUP BY range
    ''');
  }

  // ==================== EXISTING QUIZ OPERATIONS ====================

  Future<int> saveQuizAttempt(QuizAttempt attempt) async {
    final db = await database;
    return await db.insert('quiz_attempts', attempt.toMap());
  }

  Future<void> saveAnswerRecords(List<AnswerRecord> records) async {
    final db = await database;
    final batch = db.batch();
    for (var record in records) {
      batch.insert('answer_records', record.toMap());
      if (!record.isCorrect) {
        final attempt = await db.query('quiz_attempts', where: 'id = ?', whereArgs: [record.attemptId]);
        if (attempt.isNotEmpty) {
          final studentId = attempt.first['studentId'];
          await db.insert('difficult_questions', {
            'studentId': studentId,
            'questionId': record.questionId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
    }
    await batch.commit();
  }

  Future<List<QuizAttempt>> getStudentAttempts(int studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'quiz_attempts',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'completedAt DESC',
    );
    return List.generate(maps.length, (i) => QuizAttempt.fromMap(maps[i]));
  }

  Future<List<Map<String, dynamic>>> getAllAttemptsWithStudentInfo() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT qa.*, u.fullName as studentName, u.username
      FROM quiz_attempts qa
      JOIN users u ON qa.studentId = u.id
      ORDER BY qa.completedAt DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT u.fullName, u.username, SUM(qa.score) as totalScore, COUNT(qa.id) as totalAttempts
      FROM users u
      JOIN quiz_attempts qa ON u.id = qa.studentId
      WHERE u.role = 'student'
      GROUP BY u.id
      ORDER BY totalScore DESC, totalAttempts ASC
      LIMIT 10
    ''');
  }

  Future<List<Question>> getDifficultQuestions(int studentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT q.* FROM questions q
      JOIN difficult_questions dq ON q.id = dq.questionId
      WHERE dq.studentId = ?
    ''', [studentId]);
    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }

  Future<void> removeFromDifficult(int studentId, int questionId) async {
    final db = await database;
    await db.delete('difficult_questions', where: 'studentId = ? AND questionId = ?', whereArgs: [studentId, questionId]);
  }

  Future<List<Map<String, dynamic>>> getUserAchievements(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT a.*, ua.awardedAt FROM achievements a
      JOIN user_achievements ua ON a.id = ua.achievementId
      WHERE ua.userId = ?
    ''', [userId]);
  }

  Future<void> checkAndAwardAchievements(int userId) async {
    final db = await database;
    final attempts = await db.query('quiz_attempts', where: 'studentId = ?', whereArgs: [userId]);
    if (attempts.length == 1) await _awardAchievement(userId, 'FIRST_QUIZ');
    final perfectScores = await db.query('quiz_attempts', where: 'studentId = ? AND score = totalQuestions', whereArgs: [userId]);
    if (perfectScores.isNotEmpty) await _awardAchievement(userId, 'PERFECT_SCORE');
    final fastAttempts = await db.query('quiz_attempts', where: 'studentId = ? AND timeTaken > 0 AND timeTaken < 30', whereArgs: [userId]);
    if (fastAttempts.isNotEmpty) await _awardAchievement(userId, 'FAST_LEARNER');
    final totalCorrect = await db.rawQuery('SELECT SUM(score) as total FROM quiz_attempts WHERE studentId = ?', [userId]);
    if (totalCorrect.isNotEmpty && (totalCorrect.first['total'] as num? ?? 0) >= 100) await _awardAchievement(userId, 'HARD_WORKING');
  }

  Future<void> _awardAchievement(int userId, String badgeCode) async {
    final db = await database;
    final achievement = await db.query('achievements', where: 'badgeCode = ?', whereArgs: [badgeCode]);
    if (achievement.isNotEmpty) {
      final achievementId = achievement.first['id'];
      final alreadyAwarded = await db.query('user_achievements', where: 'userId = ? AND achievementId = ?', whereArgs: [userId, achievementId]);
      if (alreadyAwarded.isEmpty) {
        await db.insert('user_achievements', {'userId': userId, 'achievementId': achievementId, 'awardedAt': DateTime.now().toIso8601String()});
      }
    }
  }
}
