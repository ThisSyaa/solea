const int maxTeamMembers = 7;

class TeamSocialLink {
  /// Tipe platform: 'github', 'instagram', atau 'linkedin'
  final String type;
  final String label;
  final String url;

  const TeamSocialLink({
    required this.type,
    required this.label,
    required this.url,
  });

  factory TeamSocialLink.fromMap(Map<String, String> map) {
    return TeamSocialLink(
      type: map['type'] ?? 'github',
      label: map['label'] ?? '',
      url: map['url'] ?? '',
    );
  }
}

class TeamMember {
  final String name;
  final String nim;
  final String role;
  final String photo;
  final List<TeamSocialLink> links;

  const TeamMember({
    required this.name,
    required this.nim,
    required this.role,
    this.photo = '',
    this.links = const [],
  });

  factory TeamMember.fromMap(Map<String, dynamic> map) {
    final rawLinks =
        (map['links'] as List<dynamic>? ?? const []);
    return TeamMember(
      name: (map['name'] as String?) ?? '',
      nim: (map['nim'] as String?) ?? '',
      role: (map['role'] as String?) ?? '',
      photo: (map['photo'] as String?) ?? '',
      links: rawLinks
          .whereType<Map<String, String>>()
          .map(TeamSocialLink.fromMap)
          .toList(),
    );
  }
}

/// Data anggota tim (maksimal 7 orang) dalam satu array objek
/// `{ name, nim, role, photo, links: [{type, label, url}] }`.
const List<Map<String, dynamic>> teamMembersData = [
  {
    'name': 'Raka Pratama',
    'nim': '2301010012',
    'role': 'UI/UX Designer & Visual Direction',
    'photo':
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
    'links': <Map<String, String>>[
      {
        'type': 'github',
        'label': 'rakapratama',
        'url': 'https://github.com/',
      },
      {
        'type': 'instagram',
        'label': '@raka.design',
        'url': 'https://instagram.com/',
      },
      {
        'type': 'linkedin',
        'label': 'Raka Pratama',
        'url': 'https://linkedin.com/',
      },
    ],
  },
  {
    'name': 'Jois Miranda Agunning Putri',
    'nim': '25051204427',
    'role': 'Frontend & Catalog Engineer',
    'photo':
        'https://media.licdn.com/dms/image/v2/D5603AQH1UXXzjaFPOA/profile-displayphoto-crop_800_800/B56ZupYGfvIsAI-/0/1768073228140?e=1795651200&v=beta&t=xG99zReVsylWlroAsANsUkFEmr8C5fxWM45qdnJGUNQ',
    'links': <Map<String, String>>[
      {
        'type': 'github',
        'label': 'MirandaAP',
        'url': 'https://github.com/MirandaAP',
      },
      {
        'type': 'instagram',
        'label': '@joismrnda',
        'url': 'https://instagram.com/joismrnda',
      },
      {
        'type': 'linkedin',
        'label': 'Jois Miranda',
        'url': 'https://www.linkedin.com/in/joismiranda',
      },
    ],
  },
  {
    'name': 'Muhammad Syafiq As Shidiq',
    'nim': '2301010001',
    'role': 'Lead Developer & Firebase Architect',
    'photo':
        'https://avatars.githubusercontent.com/u/174694675?v=4',
    'links': <Map<String, String>>[
      {
        'type': 'github',
        'label': 'ThisSyaa',
        'url': 'https://github.com/ThisSyaa',
      },
      {
        'type': 'instagram',
        'label': '@syaaaaxii',
        'url': 'https://instagram.com/',
      },
      {
        'type': 'linkedin',
        'label': 'Muhammad Syafiq asshidiq',
        'url': 'https://linkedin.com/',
      },
    ],
  },
  {
    'name': 'Irfan Feby M',
    'nim': '25051204403',
    'role': 'Backend',
    'photo': 'https://avatars.githubusercontent.com/u/266764259?s=400&u=7c4256e9d2c2e21585779c78a8dc0d443db2837d&v=4',
    'links': <Map<String, String>>[
      {
        'type': 'github',
        'label': 'irfanfebym-sketch',
        'url': 'https://github.com/irfanfebym-sketch',
      },
      {
        'type': 'instagram',
        'label': '@irfanfebym',
        'url': 'https://instagram.com/',
      },
      {
        'type': 'linkedin',
        'label': 'Irfan Feby M',
        'url': 'https://linkedin.com/',
      },
    ],
  },
{
  'name': 'Celvin Saputra Pratama',
  'nim': '25051204439',
  'role': 'Frontend Developer',
  'photo': 'https://i.ibb.co.com/svHmmZXW/walpaper.jpg',
  'links': <Map<String, String>>[
    {
      'type': 'github',
      'label': 'kelvinsaputraprt-code',
      'url': 'https://github.com/kelvinsaputraprt-code',
    },
    {
      'type': 'instagram',
      'label': '@celvinssspp',
      'url': 'https://instagram.com/celvinssspp',
    },
    {
      'type': 'linkedin',
      'label': 'Celvin Saputra Pratama',
      'url': 'https://www.linkedin.com/in/celvinsaputra-pratama-0ab24b44a',
    },
  ],
},
  {
    'name': 'Bagas Prakoso',
    'nim': '2301010052',
    'role': 'Authentication & Security Specialist',
    'photo':
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80',
    'links': <Map<String, String>>[
      {
        'type': 'github',
        'label': 'bagasprakoso',
        'url': 'https://github.com/',
      },
      {
        'type': 'instagram',
        'label': '@bagas.prk',
        'url': 'https://instagram.com/',
      },
      {
        'type': 'linkedin',
        'label': 'Bagas Prakoso',
        'url': 'https://linkedin.com/',
      },
    ],
  },
  {
    'name': 'Alya Maharani',
    'nim': '2301010063',
    'role': 'Quality Assurance & Documentation',
    // Contoh anggota tanpa URL foto -> otomatis menampilkan placeholder siluet
    'photo': '',
    'links': <Map<String, String>>[
      {
        'type': 'github',
        'label': 'alyamaharani',
        'url': 'https://github.com/',
      },
      {
        'type': 'instagram',
        'label': '@alya.mhrn',
        'url': 'https://instagram.com/',
      },
      {
        'type': 'linkedin',
        'label': 'Alya Maharani',
        'url': 'https://linkedin.com/',
      },
    ],
  },
];

/// Daftar anggota tim yang sudah dibatasi maksimal `maxTeamMembers` (7 orang).
final List<TeamMember> defaultTeamMembers = teamMembersData
    .take(maxTeamMembers)
    .map(TeamMember.fromMap)
    .toList();
