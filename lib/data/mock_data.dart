import '../models/movie.dart';
import '../models/cast_member.dart';
import '../models/episode.dart';

class MockData {
  static const Movie featuredHeroMovie = Movie(
    id: 'hero_1',
    title: 'NEBULA DRIFT',
    synopsis:
        'In the year 2144, humanity\'s last hope rests on a lone scout navigating the edge of a dying galaxy. A visual masterpiece of scale, light, and silence.',
    rating: 4.9,
    tags: ['4K', 'EXCLUSIVE'],
    genres: ['Sci-Fi', 'Adventure', 'Mystery'],
    posterUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDzKwJZepW88E0hJiIBM4Vxba1Rpq3U50h9tkiPvp7xZJQK-mO2jMmpBbUeSRQbi8RFiA4qI7p9OGX6D5KDd63ubsU9_i6fdkW6RC-mW64KoyzIwowoe6zwbzI62x9DLZTHlWO0eABkKj5stmyuXQDPc12JQywmKdc1yNjmFOwic1xpNRC0aXvh3z81Pg_DP6CVgOLwf9QQzDXP88WrgFJo4NERkeXKJgYInTZCxEoQaioAg0i_neIHlapRuo2-ngOhlcuZFphmeA',
    backdropUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDzKwJZepW88E0hJiIBM4Vxba1Rpq3U50h9tkiPvp7xZJQK-mO2jMmpBbUeSRQbi8RFiA4qI7p9OGX6D5KDd63ubsU9_i6fdkW6RC-mW64KoyzIwowoe6zwbzI62x9DLZTHlWO0eABkKj5stmyuXQDPc12JQywmKdc1yNjmFOwic1xpNRC0aXvh3z81Pg_DP6CVgOLwf9QQzDXP88WrgFJo4NERkeXKJgYInTZCxEoQaioAg0i_neIHlapRuo2-ngOhlcuZFphmeA',
    duration: '2h 15m',
    releaseYear: '2025',
    dailymotionVideoId: 'x8m00bc',
    isNewRelease: true,
  );

  static const Movie detailFeaturedMovie = Movie(
    id: 'detail_1',
    title: 'Aetherius: The Silent Void',
    synopsis:
        'In a future where humanity has colonized the outer rim of the galaxy, a lone scout pilot discovers a sentient anomaly at the edge of the Etherius system. As the fabric of reality begins to blur, she must navigate a celestial labyrinth of ancient secrets to save civilization.',
    rating: 8.9,
    tags: ['IMAX', '4K'],
    genres: ['Sci-Fi', 'Thriller', 'Adventure'],
    posterUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCI3PC1nC90mF2zXmj_85_blqtMFt4hNK-CkrVYSNaKgh371rYW2QzeHy_hg4-VBGY8cdEIEaqTVSQBAqqH4YdffYUSngZf6ayx3MAC7v4ixR-bXqm_YPnPj6Gv3gRuWwjMZ4kzK7jon2saDfXFsd1bowJ-UiGl_npMbFtTFl7_LQ2jKXKVfd1QCxY69Uu0aMw5HMoUr6KT_Fvx5id5eUiewpFsL-8IvG2P9Y4Ycw6je7pM8K1531wGkevokwNcMP0m4C1img-zUw',
    backdropUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCI3PC1nC90mF2zXmj_85_blqtMFt4hNK-CkrVYSNaKgh371rYW2QzeHy_hg4-VBGY8cdEIEaqTVSQBAqqH4YdffYUSngZf6ayx3MAC7v4ixR-bXqm_YPnPj6Gv3gRuWwjMZ4kzK7jon2saDfXFsd1bowJ-UiGl_npMbFtTFl7_LQ2jKXKVfd1QCxY69Uu0aMw5HMoUr6KT_Fvx5id5eUiewpFsL-8IvG2P9Y4Ycw6je7pM8K1531wGkevokwNcMP0m4C1img-zUw',
    duration: '2h 45m',
    releaseYear: '2024',
    dailymotionVideoId: 'x8lzs3e',
    isSeries: true,
    episodes: [
      Episode(
        id: 'ep_1',
        episodeNumber: 1,
        seasonNumber: 1,
        title: 'Episode 1: The Anomaly',
        duration: '45m',
        thumbnail:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCI3PC1nC90mF2zXmj_85_blqtMFt4hNK-CkrVYSNaKgh371rYW2QzeHy_hg4-VBGY8cdEIEaqTVSQBAqqH4YdffYUSngZf6ayx3MAC7v4ixR-bXqm_YPnPj6Gv3gRuWwjMZ4kzK7jon2saDfXFsd1bowJ-UiGl_npMbFtTFl7_LQ2jKXKVfd1QCxY69Uu0aMw5HMoUr6KT_Fvx5id5eUiewpFsL-8IvG2P9Y4Ycw6je7pM8K1531wGkevokwNcMP0m4C1img-zUw',
        dailymotionVideoId: 'x8lzs3e',
      ),
      Episode(
        id: 'ep_2',
        episodeNumber: 2,
        seasonNumber: 1,
        title: 'Episode 2: Celestial Labyrinth',
        duration: '48m',
        thumbnail:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDzKwJZepW88E0hJiIBM4Vxba1Rpq3U50h9tkiPvp7xZJQK-mO2jMmpBbUeSRQbi8RFiA4qI7p9OGX6D5KDd63ubsU9_i6fdkW6RC-mW64KoyzIwowoe6zwbzI62x9DLZTHlWO0eABkKj5stmyuXQDPc12JQywmKdc1yNjmFOwic1xpNRC0aXvh3z81Pg_DP6CVgOLwf9QQzDXP88WrgFJo4NERkeXKJgYInTZCxEoQaioAg0i_neIHlapRuo2-ngOhlcuZFphmeA',
        dailymotionVideoId: 'x8k92b1',
      ),
      Episode(
        id: 'ep_3',
        episodeNumber: 3,
        seasonNumber: 1,
        title: 'Episode 3: Event Horizon',
        duration: '52m',
        thumbnail:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCOkfsuQtpG1yU8Emu3rsRkcou67wgqqAIMaqeu_rWFqBgfA1HEhmJtR7EsBfPAN6Cu_qJkqRjgGrFlKtK9vRUDQcckzzU-ELd3-CUX8H1OCI8suqdNDdptZf_sZeN8sDWpTUmsD4lVa2uDSJ2K8xf8AyxShdcHMhXJhGGEpV2kgA4d_hRYqfdAOGfcQ4bxmi5Lo32lTPmb2a9uC4sF6eZngqLT2Tv8IXAGfcB2e8pevnUac2wsHPSc1kfqUEguNyMUWrGdWDJltg',
        dailymotionVideoId: 'x8m00bc',
      ),
    ],
    cast: [
      CastMember(
        id: 'c1',
        name: 'Nolan Vance',
        role: 'Director',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDhQgXL2CguFH1qQnMAbCEl8j91Quz5x6uxWBPFk2yWZ2trmS0M4jqHKpGYCHzP6uOAzpW05YlP7cLbU0PeeFPBV2N51VH5B3EKseh1ILk8vMcdCxq94rosX-rd9bItIkbnf7tWNQphFa4L3cgDL-z13WgE6TAKabsh9xC0uM7XZ7JavskR6ZAfWABVF99qZLsbTsHU5wDKjBe86J9e3z_dFhlUj5VVxkNP-SUhI5MnlBbO_ntTQ5nDNgcARmHQz1ZNHdzsh_adLQ',
      ),
      CastMember(
        id: 'c2',
        name: 'Elena Solara',
        role: 'Major Nova',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAGa7Ey-zRVxGjo8PdupOHw3ME4mEjqsB6j98JUnLoCGqw1lOFuTb2uDIUNKg8t5_gQKOts1JAS2jQkergVMFRohx7KGZi0rDSC4DJiwtiYHvJWscKUyvhxKGIN4WuBp1wtkH-B-V5FSNiCgHxODW4yoMwtlttHNZLpkKv0gHV0Dbuk-Rma6FPnfCJgFDe2r8Hxx1XdP05K3zB8RazEHJdtxJaNU9Q3ftb0Bvv4qy0b9HZ6SfZPnQFjQhIf4MN8-HSocIVk51JW-w',
      ),
      CastMember(
        id: 'c3',
        name: 'Marcus Thorne',
        role: 'Commander',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuD_-VbLt3RgKP5fb_DLZnCIkRJny2_sBCqKZ0yM7JQ6XyoNtUq4y5hpk2_Ep2eQVUo-mM4kJ6AicTaKLrutVf0OFUVnt6mp44RUSGt3_s5wAH8Q4SyqNRc3EAy1ncwJ169kAxD00cdX454xiiV-3x3uWByLImDGrE18HyvmW6V-Ku3y_2npClHVcyRzt9_wgACZ4pp48lbBsq8VyfNEHLmVB2TbB6xb_5pWu7gHO1XCWWmfIV7SDw3WKOyCA3LhJhbTfgPOQDFv8g',
      ),
    ],
  );

  static const List<Movie> continueWatchingMovies = [
    Movie(
      id: 'cw_1',
      title: 'Neon Horizon',
      synopsis: 'A gritty cyberpunk detective navigates rain-slicked streets.',
      rating: 4.8,
      tags: [],
      genres: ['Cyberpunk'],
      posterUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB0nEOD1bpFRM07LR8t_bvrAyNErI_pKHFa_cwjtNOEsqX5oe7AfU6ZY9UvDNkBlsZ3-FQXPxA58GrskaQzKgjBRBL1t5kXdECRO9VGKcEOurIz-Kcmc2CnxFyVyR94LdPIqKHyN1KIlUrKjFTbaRts6wrzRzoEVF2-h1YxdIkC1JuJixHeQbMnuOull79QEG9GlUPuGoPNDG7fFX6MXv2tWDAvC0R3LScSBYcmm1yuQRHjNSlNzRqaRt-4wzjYYwTG2--_ebcvKw',
      backdropUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB0nEOD1bpFRM07LR8t_bvrAyNErI_pKHFa_cwjtNOEsqX5oe7AfU6ZY9UvDNkBlsZ3-FQXPxA58GrskaQzKgjBRBL1t5kXdECRO9VGKcEOurIz-Kcmc2CnxFyVyR94LdPIqKHyN1KIlUrKjFTbaRts6wrzRzoEVF2-h1YxdIkC1JuJixHeQbMnuOull79QEG9GlUPuGoPNDG7fFX6MXv2tWDAvC0R3LScSBYcmm1yuQRHjNSlNzRqaRt-4wzjYYwTG2--_ebcvKw',
      duration: '45m',
      releaseYear: '2024',
      dailymotionVideoId: 'x8m00bc',
      watchProgress: 0.67,
      episodeInfo: 'S1 : E4',
    ),
    Movie(
      id: 'cw_2',
      title: 'Timeless Craft',
      synopsis: 'Close up exploration of luxury horology and engineering.',
      rating: 4.9,
      tags: [],
      genres: ['Documentary'],
      posterUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAuKzuU4UY7Xgvq3MLeSoWi1cOaJYVGDnL91gkP48-5Dvln_m-vdnbEdgVjHHvD1gzUNagyV90A3f0gqbuckFxz5XuzACZ44JDcllG-EQqG39rm4cIJGIUxK4otNmE7vOgL16J-7vcjnvps6rceu9tia0RPWBJOiCqj4-myH9yGzJWhSS8GAgU8EUZlsGCoQuyRJABuxxPKwsPWAN4SRm5VpF9I3-K88XiUkfIxixI3e4USW3thuMc4Mp0jwHo4ibihHald1Fsb9w',
      backdropUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAuKzuU4UY7Xgvq3MLeSoWi1cOaJYVGDnL91gkP48-5Dvln_m-vdnbEdgVjHHvD1gzUNagyV90A3f0gqbuckFxz5XuzACZ44JDcllG-EQqG39rm4cIJGIUxK4otNmE7vOgL16J-7vcjnvps6rceu9tia0RPWBJOiCqj4-myH9yGzJWhSS8GAgU8EUZlsGCoQuyRJABuxxPKwsPWAN4SRm5VpF9I3-K88XiUkfIxixI3e4USW3thuMc4Mp0jwHo4ibihHald1Fsb9w',
      duration: '58m',
      releaseYear: '2024',
      dailymotionVideoId: 'x8lzs3e',
      watchProgress: 0.72,
      episodeInfo: '42:15 / 58:00',
    ),
  ];

  static const List<Movie> trendingMovies = [
    Movie(
      id: 't_1',
      title: 'Silicon Soul',
      synopsis: 'A sleek android woman reveals optical neural pathways.',
      rating: 4.9,
      tags: ['4K', 'IMAX'],
      genres: ['Sci-Fi', 'Drama'],
      posterUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCOkfsuQtpG1yU8Emu3rsRkcou67wgqqAIMaqeu_rWFqBgfA1HEhmJtR7EsBfPAN6Cu_qJkqRjgGrFlKtK9vRUDQcckzzU-ELd3-CUX8H1OCI8suqdNDdptZf_sZeN8sDWpTUmsD4lVa2uDSJ2K8xf8AyxShdcHMhXJhGGEpV2kgA4d_hRYqfdAOGfcQ4bxmi5Lo32lTPmb2a9uC4sF6eZngqLT2Tv8IXAGfcB2e8pevnUac2wsHPSc1kfqUEguNyMUWrGdWDJltg',
      backdropUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCOkfsuQtpG1yU8Emu3rsRkcou67wgqqAIMaqeu_rWFqBgfA1HEhmJtR7EsBfPAN6Cu_qJkqRjgGrFlKtK9vRUDQcckzzU-ELd3-CUX8H1OCI8suqdNDdptZf_sZeN8sDWpTUmsD4lVa2uDSJ2K8xf8AyxShdcHMhXJhGGEpV2kgA4d_hRYqfdAOGfcQ4bxmi5Lo32lTPmb2a9uC4sF6eZngqLT2Tv8IXAGfcB2e8pevnUac2wsHPSc1kfqUEguNyMUWrGdWDJltg',
      duration: '2h 10m',
      releaseYear: '2024',
      dailymotionVideoId: 'x8m00bc',
    ),
    Movie(
      id: 't_2',
      title: 'Lumina Garden',
      synopsis: 'Bioluminescent alien flora on a distant hyper-planet.',
      rating: 4.7,
      tags: ['VIP'],
      genres: ['Fantasy'],
      posterUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBmLS2hoV0rCyd1sd0CNfobQ4hJud02AvHxoiypJrYPInp4y3m-R-TkiIpFuCupbvHf4oWwEFnK9794mbPpGYEYw8qsTIrSVtRxlLzqOTUYk1JTuaAVfdL3etc4QSQNwbDPsQzyMY_mg8ERbydfGrMILI5M1EhPGBu7cueFyM2a7e6KLvEQM5FDcge8U1QYhhUONsQPQYvV_vaPr9GnKkKarIilRhQ5J9A3gZDsYlei7Scj71mT5JNk1Bm8uU9ryVQOpE2f8mPJFg',
      backdropUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBmLS2hoV0rCyd1sd0CNfobQ4hJud02AvHxoiypJrYPInp4y3m-R-TkiIpFuCupbvHf4oWwEFnK9794mbPpGYEYw8qsTIrSVtRxlLzqOTUYk1JTuaAVfdL3etc4QSQNwbDPsQzyMY_mg8ERbydfGrMILI5M1EhPGBu7cueFyM2a7e6KLvEQM5FDcge8U1QYhhUONsQPQYvV_vaPr9GnKkKarIilRhQ5J9A3gZDsYlei7Scj71mT5JNk1Bm8uU9ryVQOpE2f8mPJFg',
      duration: '1h 50m',
      releaseYear: '2024',
      dailymotionVideoId: 'x8k92b1',
    ),
  ];

  static const List<Movie> animeMovies = [
    Movie(
      id: 'an_1',
      title: 'Chrono Blade Zero',
      synopsis: 'A high-octane anime masterpiece set in a floating neon Tokyo.',
      rating: 4.9,
      tags: ['ANIME', '4K'],
      genres: ['Anime', 'Action'],
      posterUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCOkfsuQtpG1yU8Emu3rsRkcou67wgqqAIMaqeu_rWFqBgfA1HEhmJtR7EsBfPAN6Cu_qJkqRjgGrFlKtK9vRUDQcckzzU-ELd3-CUX8H1OCI8suqdNDdptZf_sZeN8sDWpTUmsD4lVa2uDSJ2K8xf8AyxShdcHMhXJhGGEpV2kgA4d_hRYqfdAOGfcQ4bxmi5Lo32lTPmb2a9uC4sF6eZngqLT2Tv8IXAGfcB2e8pevnUac2wsHPSc1kfqUEguNyMUWrGdWDJltg',
      backdropUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCOkfsuQtpG1yU8Emu3rsRkcou67wgqqAIMaqeu_rWFqBgfA1HEhmJtR7EsBfPAN6Cu_qJkqRjgGrFlKtK9vRUDQcckzzU-ELd3-CUX8H1OCI8suqdNDdptZf_sZeN8sDWpTUmsD4lVa2uDSJ2K8xf8AyxShdcHMhXJhGGEpV2kgA4d_hRYqfdAOGfcQ4bxmi5Lo32lTPmb2a9uC4sF6eZngqLT2Tv8IXAGfcB2e8pevnUac2wsHPSc1kfqUEguNyMUWrGdWDJltg',
      duration: '2h 05m',
      releaseYear: '2025',
      isAnime: true,
      dailymotionVideoId: 'x8m00bc',
    ),
  ];

  static const List<Movie> searchResults = [
    Movie(
      id: 'sr_1',
      title: 'Crystalline Horizon',
      synopsis: 'A futuristic spaceship touches down on a dual sun world.',
      rating: 4.9,
      tags: ['IMAX'],
      genres: ['Sci-Fi'],
      posterUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAv9iz_bz40GHv5aKBisU2tp_LiSCnA5P4w8NrWIM3350mujDKF5DzOlYchE7XONCqMmB_HtaK1qdgu_LV4GNlCU7FwjZFE4v7DOLac2JlBEgG9WDrkEgGGMsVyew6oeB5uLatyMQd4smK-41wS_UDMV6MBnwqZcctxeK4KUo3JfjbzzglwMSNxtxgxt9mbn_tRs3Df7lbAtDNanQjfgCCepjcFR5NRIAcIxiZczrGmMDO6Lh919c0TXqtlUwaGVKdBhBPOsvgZqQ',
      backdropUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAv9iz_bz40GHv5aKBisU2tp_LiSCnA5P4w8NrWIM3350mujDKF5DzOlYchE7XONCqMmB_HtaK1qdgu_LV4GNlCU7FwjZFE4v7DOLac2JlBEgG9WDrkEgGGMsVyew6oeB5uLatyMQd4smK-41wS_UDMV6MBnwqZcctxeK4KUo3JfjbzzglwMSNxtxgxt9mbn_tRs3Df7lbAtDNanQjfgCCepjcFR5NRIAcIxiZczrGmMDO6Lh919c0TXqtlUwaGVKdBhBPOsvgZqQ',
      duration: '2h 45m',
      releaseYear: '2025',
      dailymotionVideoId: 'x8lzs3e',
    ),
    Movie(
      id: 'sr_2',
      title: 'Violet Shadow',
      synopsis: 'A detective story under neon lights in a rain-slicked city.',
      rating: 4.7,
      tags: ['4K'],
      genres: ['Mystery'],
      posterUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCTysGIZyj8sEpT2pK61ephTXg2oIvlZ0D-by5zhjnwpgGCXRR8iUpfUkbXxwLY3Cd_LuNE1BGb8_Apj1-8InAvjICYgkiXnWoSPHGJgkBBLXJJI2htqdwPGM5g6gRBzspybnLD3HiVDRd0zWzaX0Zn9eqUkcSzUR-ds2EL_G0t9EdBl3SSwsnIrkwCv-VTTeVS2hWwrNiKic9DGSQCPKmIuP2lKgFOsKFLfZzaN6RpV-46t9QQKQzb4e9NxriILHDL1S0I3um8NQ',
      backdropUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCTysGIZyj8sEpT2pK61ephTXg2oIvlZ0D-by5zhjnwpgGCXRR8iUpfUkbXxwLY3Cd_LuNE1BGb8_Apj1-8InAvjICYgkiXnWoSPHGJgkBBLXJJI2htqdwPGM5g6gRBzspybnLD3HiVDRd0zWzaX0Zn9eqUkcSzUR-ds2EL_G0t9EdBl3SSwsnIrkwCv-VTTeVS2hWwrNiKic9DGSQCPKmIuP2lKgFOsKFLfZzaN6RpV-46t9QQKQzb4e9NxriILHDL1S0I3um8NQ',
      duration: '1h 58m',
      releaseYear: '2024',
      dailymotionVideoId: 'x8m00bc',
    ),
  ];

  static const Map<String, dynamic> adminStats = {
    'totalViews': '1.42M',
    'activeStreams': '18,490',
    'totalTitles': 428,
    'dailymotionLinks': 1250,
  };
}
