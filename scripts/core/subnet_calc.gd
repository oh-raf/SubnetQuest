class_name SubnetCalc
extends RefCounted
## Engine Matematis Subnetting IPv4, FLSM, VLSM, Validasi Per-Field & Generator Tutorial.

static func is_valid_ip(ip_str: String) -> bool:
	var clean := ip_str.strip_edges()
	var parts := clean.split(".")
	if parts.size() != 4:
		return false
	for p in parts:
		if p.is_empty() or not p.is_valid_int():
			return false
		var v := p.to_int()
		if v < 0 or v > 255:
			return false
	return true

static func ip_to_int(ip_str: String) -> int:
	if not is_valid_ip(ip_str):
		return -1
	var p := ip_str.strip_edges().split(".")
	return (p[0].to_int() << 24) | (p[1].to_int() << 16) | (p[2].to_int() << 8) | p[3].to_int()

static func int_to_ip(val: int) -> String:
	var a := (val >> 24) & 0xFF
	var b := (val >> 16) & 0xFF
	var c := (val >> 8) & 0xFF
	var d := val & 0xFF
	return "%d.%d.%d.%d" % [a, b, c, d]

static func octet_to_bin(octet: int) -> String:
	var v := clampi(octet, 0, 255)
	var s := ""
	for i in range(7, -1, -1):
		s += "1" if ((v >> i) & 1) == 1 else "0"
	return s

static func bin_to_octet(bin_str: String) -> int:
	var clean := bin_str.strip_edges()
	var total := 0
	for i in clean.length():
		total = (total << 1) | (1 if clean[i] == "1" else 0)
	return clampi(total, 0, 255)

static func ip_to_binary_dotted(ip_str: String) -> String:
	if not is_valid_ip(ip_str):
		return "00000000.00000000.00000000.00000000"
	var p := ip_str.strip_edges().split(".")
	var out: Array[String] = []
	for part in p:
		out.append(octet_to_bin(part.to_int()))
	return ".".join(out)

static func prefix_to_mask_int(prefix: int) -> int:
	if prefix <= 0:
		return 0
	if prefix >= 32:
		return 0xFFFFFFFF
	return ((0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF)

static func prefix_to_mask(prefix: int) -> String:
	return int_to_ip(prefix_to_mask_int(clampi(prefix, 0, 32)))

static func parse_prefix(mask_or_prefix: String) -> int:
	var s := mask_or_prefix.strip_edges()
	if s.is_empty():
		return -1
	if s.begins_with("/"):
		s = s.substr(1).strip_edges()
	if s.is_valid_int():
		var p := s.to_int()
		return p if (p >= 8 and p <= 30) else -1
	if is_valid_ip(s):
		var m_int := ip_to_int(s)
		for p in range(8, 31):
			if prefix_to_mask_int(p) == m_int:
				return p
	return -1

static func smallest_prefix_for_hosts(needed_hosts: int) -> int:
	for host_bits in range(2, 17):
		var usable := (1 << host_bits) - 2
		if usable >= needed_hosts:
			return 32 - host_bits
	return 24

static func calculate_subnet(ip_str: String, prefix: int) -> Dictionary:
	var ip_val := ip_to_int(ip_str)
	var p := clampi(prefix, 8, 30)
	var mask_val := prefix_to_mask_int(p)
	var net_val := ip_val & mask_val
	var host_bits := 32 - p
	var block_size := 1 << host_bits
	var bc_val := net_val | (block_size - 1)
	var usable := maxi(0, block_size - 2)
	var first_octet := (ip_val >> 24) & 0xFF
	var ip_class := "C"
	if first_octet >= 1 and first_octet <= 126:
		ip_class = "A"
	elif first_octet >= 128 and first_octet <= 191:
		ip_class = "B"
	elif first_octet >= 224 and first_octet <= 239:
		ip_class = "D (Multicast)"
	elif first_octet >= 240:
		ip_class = "E (Eksperimental)"
	return {
		"network_int": net_val,
		"broadcast_int": bc_val,
		"network_address": int_to_ip(net_val),
		"broadcast_address": int_to_ip(bc_val),
		"subnet_mask": int_to_ip(mask_val),
		"prefix": p,
		"host_bits": host_bits,
		"block_size": block_size,
		"usable_hosts": usable,
		"first_host": int_to_ip(net_val + 1),
		"last_host": int_to_ip(bc_val - 1),
		"ip_class": ip_class
	}

static func check_overlap(net_a: int, bc_a: int, net_b: int, bc_b: int) -> bool:
	return net_a <= bc_b and net_b <= bc_a

static func validate_building_submission(
	bldg: Dictionary,
	net_in: String,
	mask_in: String,
	bc_in: String,
	active_allocations: Array[Dictionary]
) -> Dictionary:
	var res := {
		"format_error": false,
		"net_ok": false,
		"mask_ok": false,
		"bc_ok": false,
		"overlap_error": false,
		"overlap_with": "",
		"wasteful_warning": false,
		"all_ok": false,
		"error_summary": "",
		"steps": []
	}

	var clean_net := net_in.strip_edges()
	var clean_mask := mask_in.strip_edges()
	var clean_bc := bc_in.strip_edges()

	var net_valid_fmt := is_valid_ip(clean_net)
	var parsed_prefix := parse_prefix(clean_mask)
	var bc_valid_fmt := is_valid_ip(clean_bc)

	if not net_valid_fmt or parsed_prefix < 0 or not bc_valid_fmt:
		res["format_error"] = true
		var bad_fields: Array[String] = []
		if not net_valid_fmt:
			bad_fields.append("Network Address (harus 4 oktet 0..255, mis. 192.168.10.0)")
		if parsed_prefix < 0:
			bad_fields.append("Subnet Mask / Prefix (gunakan format /26 atau 255.255.255.192)")
		if not bc_valid_fmt:
			bad_fields.append("Broadcast Address (harus 4 oktet 0..255, mis. 192.168.10.127)")
		res["error_summary"] = "Kesalahan Format Input pada: " + ", ".join(bad_fields)
		res["steps"] = generate_step_by_step_tutorial(bldg, clean_net, clean_mask, clean_bc, res)
		return res

	var exp_net := str(bldg.get("expected_network", ""))
	var exp_prefix := int(bldg.get("expected_prefix", 24))
	var exp_bc := str(bldg.get("expected_broadcast", ""))
	var needed_hosts := int(bldg.get("needed_hosts", 10))

	res["net_ok"] = (clean_net == exp_net)
	res["mask_ok"] = (parsed_prefix == exp_prefix)
	res["bc_ok"] = (clean_bc == exp_bc)

	# Cek apakah pemain memasukkan prefix yang terlalu boros (kapasitas jauh di atas kebutuhan)
	if not res["mask_ok"] and parsed_prefix < exp_prefix:
		var calc_user := calculate_subnet(clean_net, parsed_prefix)
		if int(calc_user["usable_hosts"]) >= needed_hosts:
			res["wasteful_warning"] = true

	# Cek overlap dengan gedung lain yang sudah aktif
	var user_calc := calculate_subnet(clean_net, parsed_prefix)
	var u_net := int(user_calc["network_int"])
	var u_bc := int(user_calc["broadcast_int"])
	var bldg_id := str(bldg.get("id", ""))
	for alloc in active_allocations:
		if str(alloc.get("id", "")) == bldg_id:
			continue
		if check_overlap(u_net, u_bc, int(alloc["net_int"]), int(alloc["bc_int"])):
			res["overlap_error"] = true
			res["overlap_with"] = str(alloc.get("name", "Gedung Lain"))
			break

	if res["net_ok"] and res["mask_ok"] and res["bc_ok"] and not res["overlap_error"]:
		res["all_ok"] = true
		res["error_summary"] = "Konfigurasi tepat! Kabel jaringan menuju gedung menyala hijau."
	else:
		var errs: Array[String] = []
		if res["overlap_error"]:
			errs.append("Rentang subnet tumpang tindih (OVERLAP) dengan " + str(res["overlap_with"]))
		if res["wasteful_warning"]:
			errs.append("Prefix /%d terlalu boros kapasitas! Gunakan prefix terkecil yang cukup (/ %d)." % [parsed_prefix, exp_prefix])
		if not res["net_ok"]:
			errs.append("Network Address belum tepat")
		if not res["mask_ok"] and not res["wasteful_warning"]:
			errs.append("Subnet Mask / Prefix belum tepat")
		if not res["bc_ok"]:
			errs.append("Broadcast Address belum tepat")
		res["error_summary"] = "Diagnosis: " + "; ".join(errs) + "."

	res["steps"] = generate_step_by_step_tutorial(bldg, clean_net, clean_mask, clean_bc, res)
	return res

static func generate_step_by_step_tutorial(
	bldg: Dictionary,
	net_in: String,
	mask_in: String,
	bc_in: String,
	res: Dictionary
) -> Array[String]:
	var exp_net := str(bldg.get("expected_network", "192.168.10.0"))
	var exp_prefix := int(bldg.get("expected_prefix", 24))
	var exp_bc := str(bldg.get("expected_broadcast", "192.168.10.255"))
	var given_ip := str(bldg.get("given_ip", exp_net + "/" + str(exp_prefix)))
	var needed := int(bldg.get("needed_hosts", 30))
	var info := calculate_subnet(exp_net, exp_prefix)
	var mask_str := str(info["subnet_mask"])
	var host_bits := int(info["host_bits"])
	var block_sz := int(info["block_size"])
	var usable := int(info["usable_hosts"])
	var first_h := str(info["first_host"])
	var last_h := str(info["last_host"])

	var steps: Array[String] = []
	steps.append("1. Identifikasi Kebutuhan & Prefix: Gedung '%s' membutuhkan %d host (acuan soal: %s). Prefix yang tepat adalah /%d atau Subnet Mask %s." % [
		str(bldg.get("short_name", "Gedung")), needed, given_ip, exp_prefix, mask_str
	])
	steps.append("2. Hitung Bit Host & Ukuran Blok: Sisa bit host = 32 - %d = %d bit. Ukuran blok subnet = 2^%d = %d alamat (kapasitas %d host valid)." % [
		exp_prefix, host_bits, host_bits, block_sz, usable
	])
	steps.append("3. Tentukan Network Address (Titik Awal): Berdasarkan kelipatan blok %d, alamat awal jaringan untuk gedung ini adalah %s." % [
		block_sz, exp_net
	])
	steps.append("4. Tentukan Broadcast Address (Titik Akhir): Broadcast = Network + Ukuran Blok - 1, sehingga jatuh pada alamat %s." % [
		exp_bc
	])
	steps.append("5. Rentang Host Valid & Pemeriksaan Inputmu: Host valid berada di %s s/d %s. (Inputmu tadi: Net='%s', Mask='%s', BC='%s')." % [
		first_h, last_h, net_in, mask_in, bc_in
	])
	return steps
