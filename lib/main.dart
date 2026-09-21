import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String resolveFontFamily(String famiglia) {
  switch (famiglia) {
    case 'Futura':
      return 'Futura';
    case 'Open Sans':
      return 'OpenSans';
    case 'Montserrat':
      return 'Montserrat';
    case 'Noto Sans':
      return 'NotoSans';
    case 'Rubik':
      return 'Rubik';
    case 'Predefinito':
    default:
      return 'Predefinito';
  }
}

void main() {
  runApp(const AppTurni());
}

class AppTurni extends StatefulWidget {
  const AppTurni({super.key});

  @override
  State<AppTurni> createState() => _AppTurniState();
}

class _AppTurniState extends State<AppTurni> {
  bool _isDarkMode = false;
  bool _caricato = false;

  @override
  void initState() {
    super.initState();
    _caricaTemaIniziale();
  }

  Future<void> _caricaTemaIniziale() async {
    try {
      final pref = await SharedPreferences.getInstance();
      setState(() {
        _isDarkMode = pref.getBool('impostazione_dark_mode') ?? false;
        _caricato = true;
      });
    } catch (_) {
      setState(() {
        _caricato = true;
      });
    }
  }

  Future<void> _salvaTema(bool valore) async {
    try {
      final pref = await SharedPreferences.getInstance();
      await pref.setBool('impostazione_dark_mode', valore);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_caricato) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        cardColor: Colors.white,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF4285F4),
          unselectedItemColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF1C1C1E),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF121212),
          selectedItemColor: Color(0xFF4285F4),
          unselectedItemColor: Colors.grey,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SchermataPrincipale(
        isDarkMode: _isDarkMode,
        onThemeChanged: (bool valore) {
          setState(() {
            _isDarkMode = valore;
          });
          _salvaTema(valore);
        },
      ),
    );
  }
}

class ModelloTurno {
  String nome;
  TimeOfDay inizio;
  TimeOfDay fine;
  Color colore;
  IconData? icona;

  ModelloTurno({
    required this.nome,
    required this.inizio,
    required this.fine,
    required this.colore,
    this.icona,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'inizio_ora': inizio.hour,
      'inizio_minuto': inizio.minute,
      'fine_ora': fine.hour,
      'fine_minuto': fine.minute,
      'colore': colore.toARGB32(),
      'icona': icona?.codePoint,
    };
  }

  factory ModelloTurno.fromMap(Map<String, dynamic> map) {
    final codePoint = map['icona'] as int?;
    return ModelloTurno(
      nome: map['nome'],
      inizio: TimeOfDay(hour: map['inizio_ora'], minute: map['inizio_minuto']),
      fine: TimeOfDay(hour: map['fine_ora'], minute: map['fine_minuto']),
      colore: Color(map['colore']),
      icona: cercaIconaDaCodePoint(codePoint),
    );
  }
}

IconData? cercaIconaDaCodePoint(int? codePoint) {
  if (codePoint == null) return null;
  const listaIcone = [
    Icons.wb_sunny_rounded,
    Icons.wb_twilight_rounded,
    Icons.nights_stay_rounded,
    Icons.work,
    Icons.star,
    Icons.local_hospital,
    Icons.directions_car,
    Icons.alarm,
  ];
  for (var icona in listaIcone) {
    if (icona.codePoint == codePoint) return icona;
  }
  return null;
}

class SchermataPrincipale extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SchermataPrincipale({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SchermataPrincipale> createState() => _SchermataPrincipaleState();
}

class _SchermataPrincipaleState extends State<SchermataPrincipale> {
  int _indiceSelezionato = 0;
  bool _caricamentoCompletato = false;
  Offset? _inizioSwipeCalendario;

  late DateTime _meseVisualizzato;
  late DateTime _giornoSelezionato;

  String _dimensioneCaratteri = "Normale";
  String _famigliaFont = "Predefinito";
  bool _usaFormato24h = true;
  String _linguaSelezionata = "Italiano";

  final Map<String, Map<String, String>> _traduzioni = {
    'Italiano': {
      'titolo_app': 'I Miei Turni',
      'riepilogo': 'Riepilogo',
      'modelli_turno': 'Modelli Turno',
      'preferenze': 'Preferenze',
      'calendario': 'Calendario',
      'totale_ore_mensili': 'Tot. ore',
      'ore_lavorate': 'Ore lavorate',
      'turni_mese': 'Turni',
      'note_mese': 'Note',
      'conteggio_ore': 'Conteggio basato sui turni inseriti',
      'note_promemoria': 'Note e Promemoria del Mese',
      'nessuna_nota': 'Nessuna nota registrata.',
      'i_tuoi_modelli': 'I Tuoi Modelli',
      'preferenze_app': 'Preferenze Applicazione',
      'personalizza': "Personalizza l'interfaccia",
      'stile_caratteri': 'Stile Caratteri',
      'dimensione_caratteri': 'Dimensione Caratteri',
      'formato_24h': 'Formato 24 Ore',
      'lingua': 'Lingua',
      'gestisci_giorno': 'Gestisci Giorno',
      'rimuovi': 'Rimuovi',
      'nota_promemoria_label': 'Nota / Promemoria:',
      'scrivi_qui': 'Scrivi qui...',
      'assegna_turno': 'Assegna un Turno:',
      'crea_modello': 'Crea Nuovo Modello Turno',
      'modifica_modello': 'Modifica Modello Turno',
      'nome_turno': 'Nome del Turno',
      'inizio': 'Inizio',
      'fine': 'Fine',
      'ora_inizio': 'Ora di inizio',
      'ora_fine': 'Ora di fine',
      'formato_24_ore': 'Formato 24 ore',
      'annulla': 'Annulla',
      'conferma': 'Conferma',
      'seleziona_colore': 'Seleziona Colore o Simbolo:',
      'salva_modello': 'Salva Modello',
      'statistiche': 'Statistiche di',
      'analisi_freq': 'Analisi dettagliata della frequenza dei turni.',
      'predefinito': 'Predefinito',
      'piccolo': 'Piccolo',
      'normale': 'Normale',
      'grande': 'Grande',
      'mattina': 'Mattina',
      'pomeriggio': 'Pomeriggio',
      'notte': 'Notte',
    },
    'English (US)': {
      'titolo_app': 'My Shifts',
      'riepilogo': 'Summary',
      'modelli_turno': 'Shift Models',
      'preferenze': 'Preferences',
      'calendario': 'Calendar',
      'totale_ore_mensili': 'Total Hours',
      'ore_lavorate': 'Hours worked',
      'turni_mese': 'Shifts',
      'note_mese': 'Notes',
      'conteggio_ore': 'Count based on entered shifts',
      'note_promemoria': 'Monthly Notes & Reminders',
      'nessuna_nota': 'No notes recorded.',
      'i_tuoi_modelli': 'Your Shift Models',
      'preferenze_app': 'App Preferences',
      'personalizza': 'Customize the interface',
      'stile_caratteri': 'Font Style',
      'dimensione_caratteri': 'Font Size',
      'formato_24h': '24-Hour Format',
      'lingua': 'Language',
      'gestisci_giorno': 'Manage Day',
      'rimuovi': 'Remove',
      'nota_promemoria_label': 'Note / Reminder:',
      'scrivi_qui': 'Write here...',
      'assegna_turno': 'Assign Shift:',
      'crea_modello': 'Create New Shift Model',
      'modifica_modello': 'Edit Shift Model',
      'nome_turno': 'Shift Name',
      'inizio': 'Start',
      'fine': 'End',
      'ora_inizio': 'Start time',
      'ora_fine': 'End time',
      'formato_24_ore': '24-hour format',
      'annulla': 'Cancel',
      'conferma': 'Confirm',
      'seleziona_colore': 'Select Color or Icon:',
      'salva_modello': 'Save Model',
      'statistiche': 'Statistics for',
      'analisi_freq': 'Detailed analysis of shift frequency.',
      'predefinito': 'Default',
      'piccolo': 'Small',
      'normale': 'Normal',
      'grande': 'Large',
      'mattina': 'Morning',
      'pomeriggio': 'Afternoon',
      'notte': 'Night',
    },
    'English (UK)': {
      'titolo_app': 'My Shifts',
      'riepilogo': 'Summary',
      'modelli_turno': 'Shift Models',
      'preferenze': 'Preferences',
      'calendario': 'Calendar',
      'totale_ore_mensili': 'Total Hours',
      'ore_lavorate': 'Hours worked',
      'turni_mese': 'Shifts',
      'note_mese': 'Notes',
      'conteggio_ore': 'Count based on entered shifts',
      'note_promemoria': 'Monthly Notes & Reminders',
      'nessuna_nota': 'No notes recorded.',
      'i_tuoi_modelli': 'Your Shift Models',
      'preferenze_app': 'App Preferences',
      'personalizza': 'Customise the interface',
      'stile_caratteri': 'Font Style',
      'dimensione_caratteri': 'Font Size',
      'formato_24h': '24-Hour Format',
      'lingua': 'Language',
      'gestisci_giorno': 'Manage Day',
      'rimuovi': 'Remove',
      'nota_promemoria_label': 'Note / Reminder:',
      'scrivi_qui': 'Write here...',
      'assegna_turno': 'Assign Shift:',
      'crea_modello': 'Create New Shift Model',
      'modifica_modello': 'Edit Shift Model',
      'nome_turno': 'Shift Name',
      'inizio': 'Start',
      'fine': 'End',
      'ora_inizio': 'Start time',
      'ora_fine': 'End time',
      'formato_24_ore': '24-hour format',
      'annulla': 'Cancel',
      'conferma': 'Confirm',
      'seleziona_colore': 'Select Colour or Icon:',
      'salva_modello': 'Save Model',
      'statistiche': 'Statistics for',
      'analisi_freq': 'Detailed analysis of shift frequency.',
      'predefinito': 'Default',
      'piccolo': 'Small',
      'normale': 'Normal',
      'grande': 'Large',
      'mattina': 'Morning',
      'pomeriggio': 'Afternoon',
      'notte': 'Night',
    },
    'Español': {
      'titolo_app': 'Mis Turnos',
      'riepilogo': 'Resumen',
      'modelli_turno': 'Modelos de Turno',
      'preferenze': 'Preferencias',
      'calendario': 'Calendario',
      'totale_ore_mensili': 'Tot. Horas',
      'ore_lavorate': 'Horas trabajadas',
      'turni_mese': 'Turnos',
      'note_mese': 'Notas',
      'conteggio_ore': 'Cálculo basado en los turnos ingresados',
      'note_promemoria': 'Notas y Recordatorios del Mes',
      'nessuna_nota': 'Sin notas registradas.',
      'i_tuoi_modelli': 'Tus Modelos',
      'preferenze_app': 'Preferencias de la Aplicación',
      'personalizza': 'Personaliza la interfaz',
      'stile_caratteri': 'Estilo de Fuente',
      'dimensione_caratteri': 'Tamaño de Fuente',
      'formato_24h': 'Formato 24 Horas',
      'lingua': 'Idioma',
      'gestisci_giorno': 'Gestionar Día',
      'rimuovi': 'Eliminar',
      'nota_promemoria_label': 'Nota / Recordatorio:',
      'scrivi_qui': 'Escribe aquí...',
      'assegna_turno': 'Asignar Turno:',
      'crea_modello': 'Crear Nuevo Modelo de Turno',
      'modifica_modello': 'Editar Modelo de Turno',
      'nome_turno': 'Nombre del Turno',
      'inizio': 'Inicio',
      'fine': 'Fin',
      'ora_inizio': 'Hora de inicio',
      'ora_fine': 'Hora de fin',
      'formato_24_ore': 'Formato de 24 horas',
      'annulla': 'Cancelar',
      'conferma': 'Confirmar',
      'seleziona_colore': 'Seleccionar Color o Icono:',
      'salva_modello': 'Guardar Modelo',
      'statistiche': 'Estadísticas de',
      'analisi_freq': 'Análisis detallado de la frecuencia de turnos.',
      'predefinito': 'Predeterminado',
      'piccolo': 'Pequeño',
      'normale': 'Normal',
      'grande': 'Grande',
      'mattina': 'Mañana',
      'pomeriggio': 'Tarde',
      'notte': 'Noche',
    },
    'Français': {
      'titolo_app': 'Mes Gardes',
      'riepilogo': 'Résumé',
      'modelli_turno': 'Modèles de Garde',
      'preferenze': 'Préférences',
      'calendario': 'Calendrier',
      'totale_ore_mensili': 'Tot. Heures',
      'ore_lavorate': 'Heures travaillées',
      'turni_mese': 'Gardes',
      'note_mese': 'Notes',
      'conteggio_ore': 'Calcul basé sur les gardes saisies',
      'note_promemoria': 'Notes et Rappels du Mois',
      'nessuna_nota': 'Aucune note enregistrée.',
      'i_tuoi_modelli': 'Vos Modèles',
      'preferenze_app': "Préférences de l'Application",
      'personalizza': "Personnalisez l'interface",
      'stile_caratteri': 'Style de Police',
      'dimensione_caratteri': 'Taille de Police',
      'formato_24h': 'Format 24 Heures',
      'lingua': 'Langue',
      'gestisci_giorno': 'Gérer le Jour',
      'rimuovi': 'Supprimer',
      'nota_promemoria_label': 'Note / Rappel:',
      'scrivi_qui': 'Écrivez ici...',
      'assegna_turno': 'Attribuer une Garde:',
      'crea_modello': 'Créer un Nouveau Modèle',
      'modifica_modello': 'Modifier le Modèle',
      'nome_turno': 'Nom de la Garde',
      'inizio': 'Début',
      'fine': 'Fin',
      'ora_inizio': 'Heure de début',
      'ora_fine': 'Heure de fin',
      'formato_24_ore': 'Format 24 heures',
      'annulla': 'Annuler',
      'conferma': 'Confirmer',
      'seleziona_colore': 'Sélectionner Couleur ou Icône:',
      'salva_modello': 'Enregistrer le Modèle',
      'statistiche': 'Statistiques de',
      'analisi_freq': 'Analyse détaillée de la fréquence des gardes.',
      'predefinito': 'Par défaut',
      'piccolo': 'Petit',
      'normale': 'Normal',
      'grande': 'Grand',
      'mattina': 'Matin',
      'pomeriggio': 'Après-midi',
      'notte': 'Nuit',
    },
    'Deutsch': {
      'titolo_app': 'Meine Schichten',
      'riepilogo': 'Übersicht',
      'modelli_turno': 'Schichtmodelle',
      'preferenze': 'Einstellungen',
      'calendario': 'Kalender',
      'totale_ore_mensili': 'Ges. Std.',
      'ore_lavorate': 'Arbeitsstunden',
      'turni_mese': 'Schichten',
      'note_mese': 'Notizen',
      'conteggio_ore': 'Berechnung basierend auf eingetragenen Schichten',
      'note_promemoria': 'Monatsnotizen & Erinnerungen',
      'nessuna_nota': 'Keine Notizen vorhanden.',
      'i_tuoi_modelli': 'Ihre Modelle',
      'preferenze_app': 'App-Einstellungen',
      'personalizza': 'Oberfläche anpassen',
      'stile_caratteri': 'Schriftstil',
      'dimensione_caratteri': 'Schriftgröße',
      'formato_24h': '24-Stunden-Format',
      'lingua': 'Sprache',
      'gestisci_giorno': 'Tag Verwalten',
      'rimuovi': 'Entfernen',
      'nota_promemoria_label': 'Notiz / Erinnerung:',
      'scrivi_qui': 'Hier schreiben...',
      'assegna_turno': 'Schicht Zuweisen:',
      'crea_modello': 'Neues Schichtmodell Erstellen',
      'modifica_modello': 'Schichtmodell Bearbeiten',
      'nome_turno': 'Schichtname',
      'inizio': 'Start',
      'fine': 'Ende',
      'ora_inizio': 'Startzeit',
      'ora_fine': 'Endzeit',
      'formato_24_ore': '24-Stunden-Format',
      'annulla': 'Abbrechen',
      'conferma': 'Bestätigen',
      'seleziona_colore': 'Farbe oder Symbol Wählen:',
      'salva_modello': 'Modell Speichern',
      'statistiche': 'Statistiken für',
      'analisi_freq': 'Detaillierte Analyse der Schichthäufigkeit.',
      'predefinito': 'Standard',
      'piccolo': 'Klein',
      'normale': 'Normal',
      'grande': 'Groß',
      'mattina': 'Morgen',
      'pomeriggio': 'Nachmittag',
      'notte': 'Nacht',
    },
  };

  String _t(String chiave) {
    return _traduzioni[_linguaSelezionata]?[chiave] ??
        _traduzioni['Italiano']![chiave] ??
        chiave;
  }

  String _traduciNomeTurno(String nome) {
    switch (nome) {
      case 'Mattina':
        return _t('mattina');
      case 'Pomeriggio':
        return _t('pomeriggio');
      case 'Notte':
        return _t('notte');
      default:
        return nome;
    }
  }

  String _nomeMese(int mese) {
    final Map<String, List<String>> mesi = {
      'Italiano': [
        "Gennaio",
        "Febbraio",
        "Marzo",
        "Aprile",
        "Maggio",
        "Giugno",
        "Luglio",
        "Agosto",
        "Settembre",
        "Ottobre",
        "Novembre",
        "Dicembre",
      ],
      'English (US)': [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      ],
      'English (UK)': [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      ],
      'Español': [
        "Enero",
        "Febrero",
        "Marzo",
        "Abril",
        "Mayo",
        "Junio",
        "Julio",
        "Agosto",
        "Septiembre",
        "Octubre",
        "Noviembre",
        "Diciembre",
      ],
      'Français': [
        "Janvier",
        "Février",
        "Mars",
        "Avril",
        "Mai",
        "Juin",
        "Juillet",
        "Août",
        "Septembre",
        "Octobre",
        "November",
        "Décembre",
      ],
      'Deutsch': [
        "Januar",
        "Februar",
        "März",
        "April",
        "Mai",
        "Juni",
        "Juli",
        "August",
        "September",
        "Oktober",
        "November",
        "Dezember",
      ],
    };
    return mesi[_linguaSelezionata]?[mese - 1] ?? mesi['Italiano']![mese - 1];
  }

  List<String> _ottieniGiorniSettimana() {
    final Map<String, List<String>> giorni = {
      'Italiano': ["LUN", "MAR", "MER", "GIO", "VEN", "SAB", "DOM"],
      'English (US)': ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
      'English (UK)': ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"],
      'Español': ["LUN", "MAR", "MIÉ", "JUE", "VIE", "SÁB", "DOM"],
      'Français': ["LUN", "MAR", "MER", "JEU", "VEN", "SAM", "DIM"],
      'Deutsch': ["MO", "DI", "MI", "DO", "FR", "SA", "SO"],
    };
    return giorni[_linguaSelezionata] ?? giorni['Italiano']!;
  }

  List<ModelloTurno> _modelliDisponibili = [];
  Map<String, Map<String, dynamic>> _databaseTurni = {};

  List<ModelloTurno> _creaTurniPredefiniti() {
    return [
      ModelloTurno(
        nome: "Mattina",
        inizio: const TimeOfDay(hour: 6, minute: 30),
        fine: const TimeOfDay(hour: 14, minute: 0),
        colore: const Color(0xFFFFF59D),
        icona: Icons.wb_sunny_rounded,
      ),
      ModelloTurno(
        nome: "Pomeriggio",
        inizio: const TimeOfDay(hour: 14, minute: 0),
        fine: const TimeOfDay(hour: 21, minute: 30),
        colore: const Color(0xFFFFCC80),
        icona: Icons.wb_twilight_rounded,
      ),
      ModelloTurno(
        nome: "Notte",
        inizio: const TimeOfDay(hour: 21, minute: 30),
        fine: const TimeOfDay(hour: 6, minute: 30),
        colore: const Color(0xFFD0E1F9),
        icona: Icons.nights_stay_rounded,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    DateTime ora = DateTime.now();
    _meseVisualizzato = DateTime(ora.year, ora.month, 1);
    _giornoSelezionato = DateTime(ora.year, ora.month, ora.day);
    _modelliDisponibili = _creaTurniPredefiniti();
    _caricaDatiLocali();
  }

  Future<void> _caricaDatiLocali() async {
    try {
      final pref = await SharedPreferences.getInstance();

      String dim = pref.getString('impostazione_font_size') ?? "Normale";
      String font = pref.getString('impostazione_font_family') ?? "Predefinito";
      if (font == "Helvetica") {
        font = "Predefinito";
      }
      bool h24 = pref.getBool('impostazione_24h') ?? true;
      String lingua = pref.getString('impostazione_lingua') ?? "Italiano";

      if (!_traduzioni.containsKey(lingua)) {
        lingua = "Italiano";
      }

      List<ModelloTurno> modelliTemp = [];
      final String? stringaModelli = pref.getString('database_modelli');
      if (stringaModelli != null && stringaModelli.isNotEmpty) {
        final List<dynamic> listaDecodificata = jsonDecode(stringaModelli);
        modelliTemp = listaDecodificata
            .map(
              (item) => ModelloTurno.fromMap(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      if (modelliTemp.isEmpty) {
        modelliTemp = _creaTurniPredefiniti();
      }

      Map<String, Map<String, dynamic>> mappaConvertita = {};
      final String? stringaCalendario = pref.getString(
        'database_calendario_turni',
      );
      if (stringaCalendario != null) {
        final Map<String, dynamic> mappaDecodificata = jsonDecode(
          stringaCalendario,
        );

        mappaDecodificata.forEach((chiave, valore) {
          Map<String, dynamic> datiGiorno = Map<String, dynamic>.from(valore);
          if (datiGiorno.containsKey('colore_val')) {
            datiGiorno['colore'] = Color(datiGiorno['colore_val']);
          }
          if (datiGiorno.containsKey('icona_codepoint') &&
              datiGiorno['icona_codepoint'] != null) {
            datiGiorno['icona'] = cercaIconaDaCodePoint(
              datiGiorno['icona_codepoint'] as int?,
            );
          }
          mappaConvertita[chiave] = datiGiorno;
        });
      }

      setState(() {
        _dimensioneCaratteri = dim;
        _famigliaFont = font;
        _usaFormato24h = h24;
        _linguaSelezionata = lingua;
        _modelliDisponibili = modelliTemp;
        _databaseTurni = mappaConvertita;
      });
    } catch (_) {
    } finally {
      setState(() {
        _caricamentoCompletato = true;
      });
    }
  }

  Future<void> _salvaImpostazioni() async {
    try {
      final pref = await SharedPreferences.getInstance();
      await pref.setString('impostazione_font_size', _dimensioneCaratteri);
      await pref.setString('impostazione_font_family', _famigliaFont);
      await pref.setBool('impostazione_24h', _usaFormato24h);
      await pref.setString('impostazione_lingua', _linguaSelezionata);
    } catch (_) {}
  }

  Future<void> _salvaModelli() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> listaMappe = _modelliDisponibili
          .map((m) => m.toMap())
          .toList();
      await pref.setString('database_modelli', jsonEncode(listaMappe));
    } catch (_) {}
  }

  Future<void> _salvaCalendario() async {
    try {
      final pref = await SharedPreferences.getInstance();
      Map<String, Map<String, dynamic>> mappaJson = {};

      _databaseTurni.forEach((chiave, valore) {
        Map<String, dynamic> copiaDati = Map<String, dynamic>.from(valore);
        if (copiaDati['colore'] is Color) {
          copiaDati['colore_val'] = (copiaDati['colore'] as Color).toARGB32();
          copiaDati.remove('colore');
        }
        if (copiaDati['icona'] is IconData) {
          copiaDati['icona_codepoint'] =
              (copiaDati['icona'] as IconData).codePoint;
          copiaDati.remove('icona');
        }
        mappaJson[chiave] = copiaDati;
      });

      await pref.setString('database_calendario_turni', jsonEncode(mappaJson));
    } catch (_) {}
  }

  bool _modelloTurnoValido(ModelloTurno modello) {
    if (modello.nome.trim().isEmpty) return false;
    final minutiInizio = modello.inizio.hour * 60 + modello.inizio.minute;
    final minutiFine = modello.fine.hour * 60 + modello.fine.minute;
    return minutiFine > minutiInizio;
  }

  void _mostraMessaggio(String testo) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(testo), behavior: SnackBarBehavior.floating),
    );
  }

  TextStyle _ottieniStileTesto({
    required String ruolo,
    FontWeight? weight,
    Color? color,
  }) {
    double dimensioneBase = 14.0;
    double moltiplicatore = 1.0;
    if (_dimensioneCaratteri == "Piccolo") moltiplicatore = 0.85;
    if (_dimensioneCaratteri == "Grande") moltiplicatore = 1.15;

    switch (ruolo) {
      case "titolo_grande":
        dimensioneBase = 22.0;
        break;
      case "titolo_sezione":
        dimensioneBase = 18.0;
        break;
      case "testo_corpo":
        dimensioneBase = 14.0;
        break;
      case "testo_secondario":
        dimensioneBase = 11.5;
        break;
      case "orario_calendario":
        dimensioneBase = 11.0;
        break;
    }
    double dimensioneFinale = dimensioneBase * moltiplicatore;
    Color coloreDefinito =
        color ?? (widget.isDarkMode ? Colors.white : Colors.black87);

    return TextStyle(
      fontSize: dimensioneFinale,
      fontWeight: weight,
      color: coloreDefinito,
      fontFamily: resolveFontFamily(_famigliaFont),
      fontFamilyFallback: const ['sans-serif'],
    );
  }

  String _formattaChiaveData(DateTime data) {
    return "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}";
  }

  String _stringaH24(TimeOfDay tempo) {
    if (!_usaFormato24h) {
      final hourOfPeriod = tempo.hourOfPeriod == 0 ? 12 : tempo.hourOfPeriod;
      final periodo = tempo.period == DayPeriod.am ? "AM" : "PM";
      final minuto = tempo.minute.toString().padLeft(2, '0');
      return "$hourOfPeriod:$minuto $periodo";
    }
    final ora = tempo.hour.toString().padLeft(2, '0');
    final minuto = tempo.minute.toString().padLeft(2, '0');
    return "$ora:$minuto";
  }

  double calcolaTotaleMese() {
    double totale = 0.0;
    _databaseTurni.forEach((chiave, dati) {
      try {
        DateTime dataTurno = DateTime.parse(chiave);
        if (dataTurno.month == _meseVisualizzato.month &&
            dataTurno.year == _meseVisualizzato.year) {
          if (dati.containsKey("ore") && dati["ore"] != null) {
            totale += (dati["ore"] as num).toDouble();
          }
        }
      } catch (_) {}
    });
    return totale;
  }

  bool esistenzaTurnoReale(String chiave) {
    if (!_databaseTurni.containsKey(chiave)) return false;
    return _databaseTurni[chiave]!["nome"].toString().isNotEmpty;
  }

  void _mostraAssegnazioneTurno(DateTime dataScelta) {
    setState(() {
      _giornoSelezionato = dataScelta;
    });

    final String chiave = _formattaChiaveData(dataScelta);
    final bool esistente = _databaseTurni.containsKey(chiave);

    final controllerNota = TextEditingController(
      text: esistente ? (_databaseTurni[chiave]?["nota"] ?? "") : "",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_t('gestisci_giorno')} - ${dataScelta.day}/${dataScelta.month}/${dataScelta.year}",
                        style: _ottieniStileTesto(
                          ruolo: "titolo_sezione",
                          weight: FontWeight.bold,
                        ),
                      ),
                      if (esistenzaTurnoReale(chiave))
                        TextButton.icon(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.redAccent,
                            size: 16,
                          ),
                          label: Text(
                            _t('rimuovi'),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _databaseTurni.remove(chiave);
                            });
                            _salvaCalendario();
                            Navigator.pop(context);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _t('nota_promemoria_label'),
                    style: _ottieniStileTesto(
                      ruolo: "testo_secondario",
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controllerNota,
                    style: _ottieniStileTesto(ruolo: "testo_corpo"),
                    decoration: InputDecoration(
                      hintText: _t('scrivi_qui'),
                      prefixIcon: const Icon(
                        Icons.edit_note,
                        color: Color(0xFF4285F4),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (testo) {
                      setState(() {
                        if (_databaseTurni.containsKey(chiave)) {
                          _databaseTurni[chiave]!["nota"] = testo;
                        } else if (testo.trim().isNotEmpty) {
                          _databaseTurni[chiave] = {
                            "nome": "",
                            "ora_inizio": "",
                            "ora_fine": "",
                            "ore": 0.0,
                            "colore": Colors.transparent,
                            "nota": testo,
                          };
                        }
                      });
                      _salvaCalendario();
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _t('assegna_turno'),
                    style: _ottieniStileTesto(
                      ruolo: "testo_secondario",
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._modelliDisponibili.map((modello) {
                    final String nomeVisibile = _traduciNomeTurno(modello.nome);
                    return ListTile(
                      dense: true,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: modello.colore,
                          shape: BoxShape.circle,
                        ),
                        child: modello.icona != null
                            ? Icon(
                                modello.icona,
                                size: 20,
                                color: Colors.black87,
                              )
                            : Center(
                                child: Text(
                                  nomeVisibile.isNotEmpty
                                      ? nomeVisibile[0].toUpperCase()
                                      : "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                      title: Text(
                        nomeVisibile,
                        style: _ottieniStileTesto(
                          ruolo: "testo_corpo",
                          weight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "${_stringaH24(modello.inizio)} - ${_stringaH24(modello.fine)}",
                        style: _ottieniStileTesto(ruolo: "testo_secondario"),
                      ),
                      onTap: () {
                        double oreCalcolate =
                            modello.fine.hour +
                            (modello.fine.minute / 60) -
                            (modello.inizio.hour +
                                (modello.inizio.minute / 60));
                        if (oreCalcolate < 0) oreCalcolate += 24;

                        setState(() {
                          _databaseTurni[chiave] = {
                            "nome": modello.nome,
                            "ora_inizio": _stringaH24(modello.inizio),
                            "ora_fine": _stringaH24(modello.fine),
                            "ore": oreCalcolate,
                            "colore": modello.colore,
                            "icona": modello.icona,
                            "nota": controllerNota.text,
                          };
                        });
                        _salvaCalendario();
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<TimeOfDay?> _mostraSelettoreOra(
    TimeOfDay iniziale, {
    required String titolo,
  }) {
    int ora = iniziale.hour;
    int minuto = iniziale.minute;
    final coloreAccento = const Color(0xFF3F51B5);

    return showDialog<TimeOfDay>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget selettoreNumero({
              required int valore,
              required int massimo,
              required ValueChanged<int> onChanged,
            }) {
              return Container(
                width: 104,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E3F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: DropdownButton<int>(
                  value: valore,
                  underline: const SizedBox(),
                  icon: Icon(Icons.expand_more, color: coloreAccento),
                  style: _ottieniStileTesto(
                    ruolo: "titolo_grande",
                    weight: FontWeight.bold,
                    color: coloreAccento,
                  ),
                  items: List.generate(
                    massimo + 1,
                    (indice) => DropdownMenuItem(
                      value: indice,
                      child: Text(indice.toString().padLeft(2, '0')),
                    ),
                  ),
                  onChanged: (valoreNuovo) {
                    if (valoreNuovo != null) onChanged(valoreNuovo);
                  },
                ),
              );
            }

            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                titolo,
                style: _ottieniStileTesto(
                  ruolo: "titolo_sezione",
                  weight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _t('formato_24_ore'),
                    style: _ottieniStileTesto(ruolo: "testo_secondario"),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      selettoreNumero(
                        valore: ora,
                        massimo: 23,
                        onChanged: (valore) =>
                            setDialogState(() => ora = valore),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          ':',
                          style: _ottieniStileTesto(
                            ruolo: "titolo_grande",
                            weight: FontWeight.bold,
                            color: coloreAccento,
                          ),
                        ),
                      ),
                      selettoreNumero(
                        valore: minuto,
                        massimo: 59,
                        onChanged: (valore) =>
                            setDialogState(() => minuto = valore),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    _t('annulla'),
                    style: TextStyle(color: coloreAccento),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: coloreAccento,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(
                    dialogContext,
                    TimeOfDay(hour: ora, minute: minuto),
                  ),
                  child: Text(_t('conferma')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostraGestioneModello({
    ModelloTurno? modelloEsistente,
    int? indiceEsistente,
  }) {
    final controllerNome = TextEditingController(
      text: modelloEsistente != null
          ? _traduciNomeTurno(modelloEsistente.nome)
          : "",
    );
    TimeOfDay inizio =
        modelloEsistente?.inizio ?? const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay fine =
        modelloEsistente?.fine ?? const TimeOfDay(hour: 16, minute: 0);
    Color coloreSelezionato =
        modelloEsistente?.colore ?? const Color(0xFFFFF176);
    IconData? iconaSelezionata =
        modelloEsistente?.icona ?? Icons.wb_sunny_rounded;

    final List<Map<String, dynamic>> paletteOpzioni = [
      {"colore": const Color(0xFFFFF176), "icona": Icons.wb_sunny_rounded},
      {"colore": const Color(0xFFFFB74D), "icona": Icons.wb_twilight_rounded},
      {"colore": const Color(0xFF64B5F6), "icona": Icons.nights_stay_rounded},
      {"colore": const Color(0xFFE57373), "icona": null},
      {"colore": const Color(0xFFFFD54F), "icona": null},
      {"colore": const Color(0xFFAED581), "icona": null},
      {"colore": const Color(0xFF81C784), "icona": null},
      {"colore": const Color(0xFF4DB6AC), "icona": null},
      {"colore": const Color(0xFF26A69A), "icona": null},
      {"colore": const Color(0xFF4DD0E1), "icona": null},
      {"colore": const Color(0xFF29B6F6), "icona": null},
      {"colore": const Color(0xFF1E88E5), "icona": null},
      {"colore": const Color(0xFF3F51B5), "icona": null},
      {"colore": const Color(0xFFAB47BC), "icona": null},
      {"colore": const Color(0xFF7E57C2), "icona": null},
      {"colore": const Color(0xFFEC407A), "icona": null},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    modelloEsistente == null
                        ? _t('crea_modello')
                        : _t('modifica_modello'),
                    style: _ottieniStileTesto(
                      ruolo: "titolo_sezione",
                      weight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controllerNome,
                    style: _ottieniStileTesto(ruolo: "testo_corpo"),
                    decoration: InputDecoration(
                      hintText: _t('nome_turno'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final t = await _mostraSelettoreOra(
                              inizio,
                              titolo: _t('ora_inizio'),
                            );
                            if (t != null) setModalState(() => inizio = t);
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFF3F51B5),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${_t('inizio')}: ${_stringaH24(inizio)}",
                                style: _ottieniStileTesto(
                                  ruolo: "testo_corpo",
                                  weight: FontWeight.bold,
                                  color: const Color(0xFF3F51B5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final t = await _mostraSelettoreOra(
                              fine,
                              titolo: _t('ora_fine'),
                            );
                            if (t != null) setModalState(() => fine = t);
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFF3F51B5),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${_t('fine')}: ${_stringaH24(fine)}",
                                style: _ottieniStileTesto(
                                  ruolo: "testo_corpo",
                                  weight: FontWeight.bold,
                                  color: const Color(0xFF3F51B5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _t('seleziona_colore'),
                    style: _ottieniStileTesto(
                      ruolo: "testo_corpo",
                      weight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: paletteOpzioni.map((opt) {
                      bool sel =
                          coloreSelezionato == opt['colore'] &&
                          iconaSelezionata == opt['icona'];
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            coloreSelezionato = opt['colore'];
                            iconaSelezionata = opt['icona'];
                          });
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: opt['colore'],
                            shape: BoxShape.circle,
                            border: sel
                                ? Border.all(color: Colors.black, width: 2.5)
                                : null,
                          ),
                          child: opt['icona'] != null
                              ? Icon(
                                  opt['icona'],
                                  color: Colors.black87,
                                  size: 22,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      final nome = controllerNome.text.trim();
                      if (nome.isEmpty) {
                        _mostraMessaggio(
                          'Inserisci un nome valido per il turno.',
                        );
                        return;
                      }

                      final nuovoModello = ModelloTurno(
                        nome: nome,
                        inizio: inizio,
                        fine: fine,
                        colore: coloreSelezionato,
                        icona: iconaSelezionata,
                      );

                      if (!_modelloTurnoValido(nuovoModello)) {
                        _mostraMessaggio(
                          'L\'orario di fine deve essere successivo a quello di inizio.',
                        );
                        return;
                      }

                      if (mounted) {
                        setState(() {
                          if (indiceEsistente != null) {
                            _modelliDisponibili[indiceEsistente] = nuovoModello;
                          } else {
                            _modelliDisponibili.add(nuovoModello);
                          }
                        });
                      }
                      _salvaModelli();
                      Navigator.pop(context);
                    },
                    child: Text(
                      _t('salva_modello'),
                      style: _ottieniStileTesto(
                        ruolo: "testo_corpo",
                        weight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _cambiaMese(int variazione) {
    setState(() {
      _meseVisualizzato = DateTime(
        _meseVisualizzato.year,
        _meseVisualizzato.month + variazione,
        1,
      );
    });
  }

  void _gestisciPointerCalendario(PointerEvent evento) {
    if (evento is PointerDownEvent) {
      _inizioSwipeCalendario = evento.position;
    } else if (evento is PointerUpEvent && _inizioSwipeCalendario != null) {
      final spostamento = evento.position - _inizioSwipeCalendario!;
      _inizioSwipeCalendario = null;
      if (spostamento.dx.abs() >= 100 &&
          spostamento.dx.abs() > spostamento.dy.abs()) {
        _cambiaMese(spostamento.dx > 0 ? -1 : 1);
      }
    } else if (evento is PointerCancelEvent) {
      _inizioSwipeCalendario = null;
    }
  }

  Widget _costruisciVistaCalendario() {
    int giorniNelMese = DateTime(
      _meseVisualizzato.year,
      _meseVisualizzato.month + 1,
      0,
    ).day;
    int primoGiornoSettimana = DateTime(
      _meseVisualizzato.year,
      _meseVisualizzato.month,
      1,
    ).weekday;
    double totaleOre = calcolaTotaleMese();

    final giorniSettimana = _ottieniGiorniSettimana();
    int totaleCelle = (primoGiornoSettimana - 1) + giorniNelMese;
    final oggi = DateTime.now();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 8, 10, 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(
              0xFF4285F4,
            ).withValues(alpha: widget.isDarkMode ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Flexible(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => _cambiaMese(-1),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "${_nomeMese(_meseVisualizzato.month)} ${_meseVisualizzato.year}",
                          style: _ottieniStileTesto(
                            ruolo: "titolo_sezione",
                            weight: FontWeight.bold,
                          ).copyWith(fontSize: 16),
                        ),
                        const SizedBox(width: 2),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => _cambiaMese(1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4285F4).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF4285F4).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_filled_rounded,
                            size: 13,
                            color: Color(0xFF4285F4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${_t('totale_ore_mensili')}: ${totaleOre.toStringAsFixed(1)} h",
                            style: _ottieniStileTesto(
                              ruolo: "testo_secondario",
                              weight: FontWeight.bold,
                              color: const Color(0xFF4285F4),
                            ).copyWith(fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: giorniSettimana
                .map(
                  (g) => Expanded(
                    child: Center(
                      child: Text(
                        g,
                        style: _ottieniStileTesto(
                          ruolo: "testo_secondario",
                          weight: FontWeight.bold,
                          color: widget.isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              int numeroRighe = (totaleCelle / 7).ceil();
              double larghezzaCella = constraints.maxWidth / 7;
              double altezzaCella = constraints.maxHeight / numeroRighe;
              double aspectRatioDinamico = larghezzaCella / altezzaCella;

              return Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _gestisciPointerCalendario,
                onPointerUp: _gestisciPointerCalendario,
                onPointerCancel: _gestisciPointerCalendario,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: aspectRatioDinamico,
                  ),
                  itemCount: totaleCelle,
                  itemBuilder: (context, index) {
                    if (index < primoGiornoSettimana - 1) {
                      return Container();
                    }
                    int giorno = index - (primoGiornoSettimana - 1) + 1;
                    DateTime dataGiorno = DateTime(
                      _meseVisualizzato.year,
                      _meseVisualizzato.month,
                      giorno,
                    );
                    String chiave = _formattaChiaveData(dataGiorno);
                    bool haTurno = esistenzaTurnoReale(chiave);
                    var datiTurno = _databaseTurni[chiave];

                    bool isSelezionato =
                        _formattaChiaveData(dataGiorno) ==
                        _formattaChiaveData(_giornoSelezionato);
                    bool isOggi =
                        dataGiorno.year == oggi.year &&
                        dataGiorno.month == oggi.month &&
                        dataGiorno.day == oggi.day;

                    Color sfondoColore = isSelezionato
                        ? const Color(0xFF4285F4)
                        : (haTurno
                              ? (datiTurno!["colore"] as Color)
                              : (isOggi
                                    ? const Color(0xFFE8F0FE)
                                    : Theme.of(context).cardColor));

                    Color testoColore;
                    if (isSelezionato) {
                      testoColore = Colors.white;
                    } else if (haTurno) {
                      testoColore = (sfondoColore.computeLuminance() < 0.5)
                          ? Colors.white
                          : Colors.black87;
                    } else {
                      testoColore = widget.isDarkMode
                          ? Colors.white
                          : Colors.black87;
                    }

                    bool haNota =
                        datiTurno?["nota"] != null &&
                        datiTurno!["nota"].toString().trim().isNotEmpty;

                    String nomeTurnoVisibile = haTurno
                        ? _traduciNomeTurno(datiTurno!["nome"].toString())
                        : "";

                    return GestureDetector(
                      onTap: () => _mostraAssegnazioneTurno(dataGiorno),
                      child: Container(
                        margin: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: sfondoColore,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: isSelezionato
                                ? Colors.white
                                : (isOggi
                                      ? const Color(0xFF4285F4)
                                      : (widget.isDarkMode
                                            ? Colors.white12
                                            : Colors.grey.shade300)),
                            width: isSelezionato || isOggi ? 1.8 : 0.8,
                          ),
                          boxShadow: isSelezionato
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4285F4,
                                    ).withValues(alpha: 0.28),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2.0,
                            horizontal: 2.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "$giorno",
                                    style: _ottieniStileTesto(
                                      ruolo: "testo_corpo",
                                      weight: FontWeight.bold,
                                      color: testoColore,
                                    ),
                                  ),
                                  if (haNota)
                                    Icon(
                                      Icons.sticky_note_2_rounded,
                                      size: 14,
                                      color: testoColore,
                                    ),
                                ],
                              ),
                              if (haTurno) ...[
                                Expanded(
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: datiTurno!["icona"] != null
                                          ? Icon(
                                              datiTurno["icona"],
                                              size: 20,
                                              color: testoColore,
                                            )
                                          : Text(
                                              nomeTurnoVisibile.isNotEmpty
                                                  ? nomeTurnoVisibile[0]
                                                        .toUpperCase()
                                                  : "",
                                              style: _ottieniStileTesto(
                                                ruolo: "titolo_sezione",
                                                weight: FontWeight.bold,
                                                color: testoColore,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 1.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        datiTurno["ora_inizio"] ?? "",
                                        textAlign: TextAlign.center,
                                        style: _ottieniStileTesto(
                                          ruolo: "orario_calendario",
                                          weight: FontWeight.bold,
                                          color: testoColore,
                                        ),
                                      ),
                                      Text(
                                        datiTurno["ora_fine"] ?? "",
                                        textAlign: TextAlign.center,
                                        style: _ottieniStileTesto(
                                          ruolo: "orario_calendario",
                                          weight: FontWeight.bold,
                                          color: testoColore.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                const Spacer(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _costruisciVistaRiepilogo() {
    final List<Widget> noteDelMese = [];
    double totaleOre = 0;
    int turniDelMese = 0;
    int noteDelMeseCount = 0;

    _databaseTurni.forEach((chiave, dati) {
      try {
        DateTime dt = DateTime.parse(chiave);
        if (dt.month == _meseVisualizzato.month &&
            dt.year == _meseVisualizzato.year) {
          final nomeTurno = dati["nome"]?.toString() ?? '';
          if (nomeTurno.isNotEmpty) {
            turniDelMese++;
            totaleOre += (dati["ore"] as num?)?.toDouble() ?? 0;
          }
          if (dati["nota"] != null &&
              dati["nota"].toString().trim().isNotEmpty) {
            noteDelMeseCount++;
            noteDelMese.add(
              Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isDarkMode
                        ? Colors.white12
                        : Colors.grey.shade300,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4285F4).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.sticky_note_2_rounded,
                        size: 21,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${dt.day}/${dt.month}",
                            style: _ottieniStileTesto(
                              ruolo: "testo_secondario",
                              weight: FontWeight.bold,
                              color: const Color(0xFF4285F4),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dati["nota"],
                            style: _ottieniStileTesto(ruolo: "testo_corpo"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      } catch (_) {}
    });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "${_t('statistiche')} ${_nomeMese(_meseVisualizzato.month)}",
          style: _ottieniStileTesto(
            ruolo: "titolo_sezione",
            weight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _t('analisi_freq'),
          style: _ottieniStileTesto(
            ruolo: "testo_corpo",
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _costruisciSchedaStatistica(
                icona: Icons.schedule_rounded,
                valore: totaleOre.toStringAsFixed(1),
                etichetta: _t('ore_lavorate'),
                colore: const Color(0xFF4285F4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _costruisciSchedaStatistica(
                icona: Icons.swap_calls_rounded,
                valore: '$turniDelMese',
                etichetta: _t('turni_mese'),
                colore: const Color(0xFF00A896),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _costruisciSchedaStatistica(
                icona: Icons.sticky_note_2_outlined,
                valore: '$noteDelMeseCount',
                etichetta: _t('note_mese'),
                colore: const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          _t('note_promemoria'),
          style: _ottieniStileTesto(
            ruolo: "titolo_sezione",
            weight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (noteDelMese.isEmpty)
          Text(
            _t('nessuna_nota'),
            style: _ottieniStileTesto(
              ruolo: "titolo_sezione",
              color: Colors.grey.shade500,
            ),
          )
        else
          ...noteDelMese,
      ],
    );
  }

  Widget _costruisciSchedaStatistica({
    required IconData icona,
    required String valore,
    required String etichetta,
    required Color colore,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colore.withValues(alpha: widget.isDarkMode ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icona, color: colore, size: 20),
          const SizedBox(height: 8),
          Text(
            valore,
            style: _ottieniStileTesto(
              ruolo: "titolo_sezione",
              weight: FontWeight.bold,
              color: colore,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            etichetta,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _ottieniStileTesto(ruolo: "testo_secondario"),
          ),
        ],
      ),
    );
  }

  Widget _costruisciVistaModelli() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _t('i_tuoi_modelli'),
              style: _ottieniStileTesto(
                ruolo: "titolo_sezione",
                weight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: Color(0xFF4285F4),
                size: 28,
              ),
              onPressed: () => _mostraGestioneModello(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._modelliDisponibili.asMap().entries.map((entry) {
          int idx = entry.key;
          ModelloTurno m = entry.value;
          final String nomeVisibile = _traduciNomeTurno(m.nome);
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: m.colore,
                child: m.icona != null
                    ? Icon(m.icona, color: Colors.black87)
                    : Text(
                        nomeVisibile.isNotEmpty
                            ? nomeVisibile[0].toUpperCase()
                            : "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              title: Text(
                nomeVisibile,
                style: _ottieniStileTesto(
                  ruolo: "testo_corpo",
                  weight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "${_stringaH24(m.inizio)} - ${_stringaH24(m.fine)}",
                style: _ottieniStileTesto(ruolo: "testo_secondario"),
              ),
              onTap: () => _mostraGestioneModello(
                modelloEsistente: m,
                indiceEsistente: idx,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _costruisciItemPreferenza({
    required IconData icona,
    required String titolo,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFF4285F4).withValues(alpha: 0.08),
          highlightColor: const Color(0xFF4285F4).withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icona, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    titolo,
                    style: _ottieniStileTesto(
                      ruolo: "testo_corpo",
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _costruisciVistaPreferenze() {
    final List<String> lingueDisponibili = [
      'Italiano',
      'English (US)',
      'English (UK)',
      'Español',
      'Français',
      'Deutsch',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _t('personalizza'),
                style: _ottieniStileTesto(
                  ruolo: "titolo_sezione",
                  weight: FontWeight.w600,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                tooltip: widget.isDarkMode ? 'Tema chiaro' : 'Tema scuro',
                icon: Icon(
                  widget.isDarkMode
                      ? Icons.wb_sunny_outlined
                      : Icons.nights_stay,
                  size: 24,
                  color: const Color(0xFF4285F4),
                ),
                onPressed: () => widget.onThemeChanged(!widget.isDarkMode),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _costruisciItemPreferenza(
          icona: Icons.language,
          titolo: _t('lingua'),
          trailing: DropdownButton<String>(
            isDense: true,
            underline: const SizedBox(),
            iconSize: 18,
            value: lingueDisponibili.contains(_linguaSelezionata)
                ? _linguaSelezionata
                : 'Italiano',
            items: lingueDisponibili
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _linguaSelezionata = val);
                _salvaImpostazioni();
              }
            },
          ),
        ),
        _costruisciItemPreferenza(
          icona: Icons.text_fields,
          titolo: _t('stile_caratteri'),
          trailing: DropdownButton<String>(
            isDense: true,
            underline: const SizedBox(),
            iconSize: 18,
            value: _famigliaFont,
            items:
                [
                      {"val": "Predefinito", "label": _t('predefinito')},
                      {"val": "Futura", "label": "Futura"},
                      {"val": "Open Sans", "label": "Open Sans"},
                      {"val": "Montserrat", "label": "Montserrat"},
                      {"val": "Noto Sans", "label": "Noto Sans"},
                      {"val": "Rubik", "label": "Rubik"},
                    ]
                    .map(
                      (f) => DropdownMenuItem(
                        value: f["val"],
                        child: Text(f["label"]!),
                      ),
                    )
                    .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _famigliaFont = val);
                _salvaImpostazioni();
              }
            },
          ),
        ),
        _costruisciItemPreferenza(
          icona: Icons.format_size,
          titolo: _t('dimensione_caratteri'),
          trailing: DropdownButton<String>(
            isDense: true,
            underline: const SizedBox(),
            iconSize: 18,
            value: _dimensioneCaratteri,
            items:
                [
                      {"val": "Piccolo", "label": _t('piccolo')},
                      {"val": "Normale", "label": _t('normale')},
                      {"val": "Grande", "label": _t('grande')},
                    ]
                    .map(
                      (d) => DropdownMenuItem(
                        value: d["val"],
                        child: Text(d["label"]!),
                      ),
                    )
                    .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _dimensioneCaratteri = val);
                _salvaImpostazioni();
              }
            },
          ),
        ),
        _costruisciItemPreferenza(
          icona: Icons.access_time,
          titolo: _t('formato_24h'),
          trailing: Switch(
            value: _usaFormato24h,
            onChanged: (val) {
              setState(() => _usaFormato24h = val);
              _salvaImpostazioni();
            },
          ),
        ),
      ],
    );
  }

  String _ottieniTitoloBarra() {
    switch (_indiceSelezionato) {
      case 0:
        return _t('calendario');
      case 1:
        return _t('riepilogo');
      case 2:
        return _t('titolo_app');
      case 3:
      default:
        return _t('preferenze');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_caricamentoCompletato) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4285F4)),
        ),
      );
    }

    final List<Widget> viste = [
      _costruisciVistaCalendario(),
      _costruisciVistaRiepilogo(),
      _costruisciVistaModelli(),
      _costruisciVistaPreferenze(),
    ];

    return Scaffold(
      appBar: _indiceSelezionato == 0
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text(
                _ottieniTitoloBarra(),
                style: _ottieniStileTesto(
                  ruolo: "titolo_grande",
                  weight: FontWeight.bold,
                ),
              ),
            ),
      body: SafeArea(child: viste[_indiceSelezionato]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceSelezionato,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _indiceSelezionato = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: _t('calendario'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.timelapse_rounded),
            label: _t('riepilogo'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.edit_calendar_rounded),
            label: _t('modelli_turno'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_suggest_rounded),
            label: _t('preferenze'),
          ),
        ],
      ),
    );
  }
}
