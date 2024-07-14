-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 14 Jul 2024 pada 07.18
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fp`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `tampilkan_peminjaman` ()   BEGIN
    DECLARE selesai INT DEFAULT 0;
    DECLARE id_peminjaman INT;
    DECLARE nama_peminjam VARCHAR(255);
    DECLARE judul_buku VARCHAR(255);
    DECLARE tanggal_pinjam DATE;
    DECLARE tanggal_kembali DATE;
    
    DECLARE peminjaman_cursor CURSOR FOR
        SELECT p.id, pg.nama, b.judul, p.tanggal_pinjam, p.tanggal_kembali
        FROM peminjaman p
        JOIN pengguna pg ON p.id_pengguna = pg.id
        JOIN buku b ON p.id_buku = b.id;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET selesai = 1;

    OPEN peminjaman_cursor;

    baca_loop: LOOP
        FETCH peminjaman_cursor INTO id_peminjaman, nama_peminjam, judul_buku, tanggal_pinjam, tanggal_kembali;
        IF selesai THEN
            LEAVE baca_loop;
        END IF;

        SELECT CONCAT('ID: ', id_peminjaman, ', Peminjam: ', nama_peminjam, ', Buku: ', judul_buku, 
                      ', Tanggal Pinjam: ', tanggal_pinjam, ', Tanggal Kembali: ', tanggal_kembali) AS Info_Peminjaman;
    END LOOP;

    CLOSE peminjaman_cursor;
END$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `hitungDendaPeminjaman` (`tanggal_kembali` DATE, `tanggal_sekarang` DATE) RETURNS INT(11)  BEGIN
    DECLARE denda INT;
    DECLARE hari_terlambat INT;
    SET hari_terlambat = DATEDIFF(tanggal_sekarang, tanggal_kembali);
    IF hari_terlambat > 0 THEN
        SET denda = hari_terlambat * 1000;
    ELSE
        SET denda = 0;
    END IF;
    RETURN denda;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `buku`
--

CREATE TABLE `buku` (
  `id` int(11) NOT NULL,
  `judul` varchar(255) NOT NULL,
  `id_penulis` int(11) NOT NULL,
  `id_kategori` int(11) NOT NULL,
  `tahun_terbit` int(11) NOT NULL,
  `isbn` varchar(13) NOT NULL,
  `jumlah_stok` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `buku`
--

INSERT INTO `buku` (`id`, `judul`, `id_penulis`, `id_kategori`, `tahun_terbit`, `isbn`, `jumlah_stok`, `created_at`, `updated_at`) VALUES
(1, 'Harry Potter and the Philosopher\'s Stone', 1, 1, 1997, '9780747532699', 10, '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(2, '1984', 2, 1, 1949, '9780451524935', 8, '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(3, 'To Kill a Mockingbird', 3, 1, 1960, '9780446310789', 12, '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(4, 'The Great Gatsby', 4, 1, 1925, '9780743273565', 6, '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(5, 'One Hundred Years of Solitude', 5, 1, 1967, '9780060883287', 7, '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(6, 'The Hobbit', 1, 1, 1937, '9780261103283', 0, '2024-07-13 21:34:45', '2024-07-13 21:34:45'),
(9, 'The Hobbit', 1, 1, 1937, '980261103283', 0, '2024-07-13 21:35:41', '2024-07-13 21:35:41'),
(11, 'Buku Test', 1, 1, 2023, '', 10, '2024-07-14 03:15:15', '2024-07-14 03:15:15');

--
-- Trigger `buku`
--
DELIMITER $$
CREATE TRIGGER `after_buku_update` AFTER UPDATE ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log_aktivitas (tabel, aksi, detail)
    VALUES ('buku', 'AFTER UPDATE', CONCAT('Buku ID: ', NEW.id, ' diupdate. Stok lama: ', OLD.jumlah_stok, ', Stok baru: ', NEW.jumlah_stok));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_buku_insert` BEFORE INSERT ON `buku` FOR EACH ROW BEGIN
    IF NEW.jumlah_stok < 0 THEN
        SET NEW.jumlah_stok = 0;
    END IF;
    
    INSERT INTO log_aktivitas (tabel, aksi, detail)
    VALUES ('buku', 'BEFORE INSERT', CONCAT('Mencoba memasukkan buku: ', NEW.judul));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `buku_fiksi`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `buku_fiksi` (
`id` int(11)
,`judul` varchar(255)
,`id_penulis` int(11)
,`tahun_terbit` int(11)
,`jumlah_stok` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `buku_fiksi_tersedia`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `buku_fiksi_tersedia` (
`id` int(11)
,`judul` varchar(255)
,`id_penulis` int(11)
,`tahun_terbit` int(11)
,`jumlah_stok` int(11)
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `buku_pinjaman`
--

CREATE TABLE `buku_pinjaman` (
  `id` int(11) NOT NULL,
  `id_buku` int(11) NOT NULL,
  `id_peminjam` int(11) NOT NULL,
  `tanggal_pinjam` date NOT NULL,
  `tanggal_kembali` date NOT NULL,
  `status` varchar(20) DEFAULT 'dipinjam'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `buku_tersedia`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `buku_tersedia` (
`id` int(11)
,`judul` varchar(255)
,`id_penulis` int(11)
,`id_kategori` int(11)
,`tahun_terbit` int(11)
,`jumlah_stok` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `info_peminjaman`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `info_peminjaman` (
`id` int(11)
,`nama_peminjam` varchar(255)
,`judul_buku` varchar(255)
,`tanggal_pinjam` date
,`tanggal_kembali` date
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `kategori`
--

CREATE TABLE `kategori` (
  `id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kategori`
--

INSERT INTO `kategori` (`id`, `nama`, `created_at`, `updated_at`) VALUES
(1, 'Fiksi', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(2, 'Non-Fiksi', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(3, 'Sains', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(4, 'Sejarah', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(5, 'Biografi', '2024-07-13 20:57:50', '2024-07-13 20:57:50');

-- --------------------------------------------------------

--
-- Struktur dari tabel `log_aktivitas`
--

CREATE TABLE `log_aktivitas` (
  `id` int(11) NOT NULL,
  `tabel` varchar(50) NOT NULL,
  `aksi` varchar(20) NOT NULL,
  `waktu` timestamp NOT NULL DEFAULT current_timestamp(),
  `detail` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `log_aktivitas`
--

INSERT INTO `log_aktivitas` (`id`, `tabel`, `aksi`, `waktu`, `detail`) VALUES
(1, 'buku', 'BEFORE INSERT', '2024-07-13 21:34:45', 'Mencoba memasukkan buku: The Hobbit'),
(4, 'buku', 'BEFORE INSERT', '2024-07-13 21:35:41', 'Mencoba memasukkan buku: The Hobbit'),
(6, 'buku', 'BEFORE INSERT', '2024-07-14 03:15:15', 'Mencoba memasukkan buku: Buku Test');

-- --------------------------------------------------------

--
-- Struktur dari tabel `peminjaman`
--

CREATE TABLE `peminjaman` (
  `id` int(11) NOT NULL,
  `id_pengguna` int(11) NOT NULL,
  `id_buku` int(11) NOT NULL,
  `tanggal_pinjam` date NOT NULL,
  `tanggal_kembali` date NOT NULL,
  `status` varchar(20) DEFAULT 'dipinjam' CHECK (`status` in ('dipinjam','dikembalikan','terlambat')),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `peminjaman`
--

INSERT INTO `peminjaman` (`id`, `id_pengguna`, `id_buku`, `tanggal_pinjam`, `tanggal_kembali`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2023-07-01', '2023-07-15', 'dipinjam', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(2, 3, 2, '2023-07-02', '2023-07-16', 'dipinjam', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(3, 5, 3, '2023-07-03', '2023-07-17', 'dipinjam', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(4, 1, 4, '2023-07-04', '2023-07-18', 'dipinjam', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(5, 3, 5, '2023-07-05', '2023-07-19', 'dipinjam', '2024-07-13 20:57:50', '2024-07-13 20:57:50');

--
-- Trigger `peminjaman`
--
DELIMITER $$
CREATE TRIGGER `after_peminjaman_insert` AFTER INSERT ON `peminjaman` FOR EACH ROW BEGIN
    UPDATE buku SET jumlah_stok = jumlah_stok - 1 WHERE id = NEW.id_buku;
    
    INSERT INTO log_aktivitas (tabel, aksi, detail)
    VALUES ('peminjaman', 'AFTER INSERT', CONCAT('Peminjaman baru dibuat untuk pengguna ID: ', NEW.id_pengguna, ', buku ID: ', NEW.id_buku));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_peminjaman_update` BEFORE UPDATE ON `peminjaman` FOR EACH ROW BEGIN
    IF NEW.tanggal_kembali < NEW.tanggal_pinjam THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tanggal kembali tidak boleh lebih awal dari tanggal pinjam';
    END IF;
    
    INSERT INTO log_aktivitas (tabel, aksi, detail)
    VALUES ('peminjaman', 'BEFORE UPDATE', CONCAT('Mencoba mengupdate peminjaman ID: ', OLD.id));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `pengguna`
--

CREATE TABLE `pengguna` (
  `id` int(11) NOT NULL,
  `nama` varchar(255) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `role` varchar(70) DEFAULT 'anggota' CHECK (`role` in ('anggota','pustakawan')),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `pengguna`
--

INSERT INTO `pengguna` (`id`, `nama`, `username`, `password`, `role`, `created_at`, `updated_at`) VALUES
(1, 'John Doe', 'johndoe', 'password123', 'anggota', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(2, 'Jane Smith', 'janesmith', 'librarian456', 'pustakawan', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(3, 'Bob Johnson', 'bobjohnson', 'member789', 'anggota', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(4, 'Alice Brown', 'alicebrown', 'staff101', 'pustakawan', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(5, 'Charlie Davis', 'charliedavis', 'reader202', 'anggota', '2024-07-13 20:57:50', '2024-07-13 20:57:50');

--
-- Trigger `pengguna`
--
DELIMITER $$
CREATE TRIGGER `before_pengguna_delete` BEFORE DELETE ON `pengguna` FOR EACH ROW BEGIN
    IF EXISTS (SELECT 1 FROM peminjaman WHERE id_pengguna = OLD.id AND status = 'dipinjam') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tidak dapat menghapus pengguna dengan peminjaman aktif';
    END IF;
    
    INSERT INTO log_aktivitas (tabel, aksi, detail)
    VALUES ('pengguna', 'BEFORE DELETE', CONCAT('Mencoba menghapus pengguna: ', OLD.nama));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `penulis`
--

CREATE TABLE `penulis` (
  `id` int(11) NOT NULL,
  `nama` varchar(255) NOT NULL,
  `negara` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `penulis`
--

INSERT INTO `penulis` (`id`, `nama`, `negara`, `created_at`, `updated_at`) VALUES
(1, 'J.K. Rowling', 'Inggris', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(2, 'George Orwell', 'Inggris', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(3, 'Harper Lee', 'Amerika Serikat', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(4, 'F. Scott Fitzgerald', 'Amerika Serikat', '2024-07-13 20:57:50', '2024-07-13 20:57:50'),
(5, 'Gabriel García Márquez', 'Kolombia', '2024-07-13 20:57:50', '2024-07-13 20:57:50');

--
-- Trigger `penulis`
--
DELIMITER $$
CREATE TRIGGER `after_penulis_delete` AFTER DELETE ON `penulis` FOR EACH ROW BEGIN
    INSERT INTO log_aktivitas (tabel, aksi, detail)
    VALUES ('penulis', 'AFTER DELETE', CONCAT('Penulis dihapus: ', OLD.nama));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur untuk view `buku_fiksi`
--
DROP TABLE IF EXISTS `buku_fiksi`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `buku_fiksi`  AS SELECT `buku`.`id` AS `id`, `buku`.`judul` AS `judul`, `buku`.`id_penulis` AS `id_penulis`, `buku`.`tahun_terbit` AS `tahun_terbit`, `buku`.`jumlah_stok` AS `jumlah_stok` FROM `buku` WHERE `buku`.`id_kategori` = (select `kategori`.`id` from `kategori` where `kategori`.`nama` = 'Fiksi') ;

-- --------------------------------------------------------

--
-- Struktur untuk view `buku_fiksi_tersedia`
--
DROP TABLE IF EXISTS `buku_fiksi_tersedia`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `buku_fiksi_tersedia`  AS SELECT `buku_tersedia`.`id` AS `id`, `buku_tersedia`.`judul` AS `judul`, `buku_tersedia`.`id_penulis` AS `id_penulis`, `buku_tersedia`.`tahun_terbit` AS `tahun_terbit`, `buku_tersedia`.`jumlah_stok` AS `jumlah_stok` FROM `buku_tersedia` WHERE `buku_tersedia`.`id_kategori` = (select `kategori`.`id` from `kategori` where `kategori`.`nama` = 'Fiksi')WITH CASCADED CHECK OPTION  ;

-- --------------------------------------------------------

--
-- Struktur untuk view `buku_tersedia`
--
DROP TABLE IF EXISTS `buku_tersedia`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `buku_tersedia`  AS SELECT `buku`.`id` AS `id`, `buku`.`judul` AS `judul`, `buku`.`id_penulis` AS `id_penulis`, `buku`.`id_kategori` AS `id_kategori`, `buku`.`tahun_terbit` AS `tahun_terbit`, `buku`.`jumlah_stok` AS `jumlah_stok` FROM `buku` WHERE `buku`.`jumlah_stok` > 0WITH CASCADEDCHECK OPTION  ;

-- --------------------------------------------------------

--
-- Struktur untuk view `info_peminjaman`
--
DROP TABLE IF EXISTS `info_peminjaman`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `info_peminjaman`  AS SELECT `p`.`id` AS `id`, `pg`.`nama` AS `nama_peminjam`, `b`.`judul` AS `judul_buku`, `p`.`tanggal_pinjam` AS `tanggal_pinjam`, `p`.`tanggal_kembali` AS `tanggal_kembali` FROM ((`peminjaman` `p` join `pengguna` `pg` on(`p`.`id_pengguna` = `pg`.`id`)) join `buku` `b` on(`p`.`id_buku` = `b`.`id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `buku`
--
ALTER TABLE `buku`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `isbn` (`isbn`),
  ADD KEY `id_penulis` (`id_penulis`),
  ADD KEY `id_kategori` (`id_kategori`);

--
-- Indeks untuk tabel `buku_pinjaman`
--
ALTER TABLE `buku_pinjaman`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_buku_peminjam` (`id_buku`,`id_peminjam`);

--
-- Indeks untuk tabel `kategori`
--
ALTER TABLE `kategori`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `log_aktivitas`
--
ALTER TABLE `log_aktivitas`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `peminjaman`
--
ALTER TABLE `peminjaman`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_buku` (`id_buku`),
  ADD KEY `idx_pengguna_tanggal` (`id_pengguna`,`tanggal_pinjam`,`tanggal_kembali`);

--
-- Indeks untuk tabel `pengguna`
--
ALTER TABLE `pengguna`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indeks untuk tabel `penulis`
--
ALTER TABLE `penulis`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_penulis_negara_nama` (`negara`,`nama`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `buku`
--
ALTER TABLE `buku`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT untuk tabel `buku_pinjaman`
--
ALTER TABLE `buku_pinjaman`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `kategori`
--
ALTER TABLE `kategori`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `log_aktivitas`
--
ALTER TABLE `log_aktivitas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `peminjaman`
--
ALTER TABLE `peminjaman`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `pengguna`
--
ALTER TABLE `pengguna`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `penulis`
--
ALTER TABLE `penulis`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `buku`
--
ALTER TABLE `buku`
  ADD CONSTRAINT `buku_ibfk_1` FOREIGN KEY (`id_penulis`) REFERENCES `penulis` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `buku_ibfk_2` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `peminjaman`
--
ALTER TABLE `peminjaman`
  ADD CONSTRAINT `peminjaman_ibfk_1` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `peminjaman_ibfk_2` FOREIGN KEY (`id_buku`) REFERENCES `buku` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
