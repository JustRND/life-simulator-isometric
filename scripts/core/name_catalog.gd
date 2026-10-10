extends RefCounted

# Small curated pools, not an exhaustive representation of each country's cultures.
const POOLS = {
	"Argentina": [["Mateo","Santiago","Benjamín","Tomás","Nicolás","Joaquín"], ["Sofía","Valentina","Camila","Lucía","Martina","Emilia"], ["García","Fernández","Rodríguez","López","Martínez","Romero"]],
	"Australia": [["Oliver","Jack","Noah","William","Thomas","Henry"], ["Charlotte","Amelia","Olivia","Isla","Ava","Matilda"], ["Wilson","Taylor","Anderson","Campbell","Harris","Thompson"]],
	"Brazil": [["Miguel","Arthur","Heitor","Davi","Gabriel","Pedro"], ["Alice","Helena","Laura","Valentina","Manuela","Beatriz"], ["Silva","Santos","Oliveira","Souza","Pereira","Costa"]],
	"Canada": [["Liam","Noah","Oliver","William","Gabriel","Étienne"], ["Olivia","Emma","Charlotte","Alice","Florence","Léa"], ["Tremblay","Gagnon","Roy","Wilson","Martin","Campbell"]],
	"Denmark": [["William","Oscar","Carl","Emil","Oliver","Magnus"], ["Alma","Clara","Agnes","Emma","Freja","Sofia"], ["Jensen","Nielsen","Hansen","Pedersen","Andersen","Christensen"]],
	"France": [["Gabriel","Louis","Raphaël","Arthur","Jules","Lucas"], ["Louise","Jade","Alice","Emma","Chloé","Manon"], ["Martin","Bernard","Dubois","Laurent","Moreau","Simon"]],
	"Germany": [["Leon","Felix","Paul","Elias","Jonas","Lukas"], ["Emilia","Hannah","Mia","Emma","Clara","Lina"], ["Müller","Schmidt","Schneider","Fischer","Weber","Wagner"]],
	"India": [["Aarav","Arjun","Rohan","Vihaan","Aditya","Ishaan"], ["Aanya","Diya","Ananya","Kavya","Meera","Isha"], ["Sharma","Verma","Patel","Rao","Iyer","Gupta"]],
	"Indonesia": [["Aditya","Bima","Dimas","Fajar","Rizky","Wahyu","Bagas","Bayu","Arif","Rafi"], ["Ayu","Citra","Dewi","Intan","Putri","Ratna","Sari","Tiara","Nadia","Kirana"], ["Pratama","Saputra","Wijaya","Nugraha","Permana","Hidayat"]],
	"Ireland": [["Oisín","Cian","Fionn","Liam","Seán","Conor"], ["Aoife","Saoirse","Niamh","Ciara","Róisín","Éabha"], ["Murphy","Kelly","Sullivan","Walsh","Ryan","Byrne"]],
	"Italy": [["Leonardo","Francesco","Alessandro","Lorenzo","Matteo","Andrea"], ["Sofia","Giulia","Aurora","Alice","Ginevra","Beatrice"], ["Rossi","Russo","Ferrari","Esposito","Bianchi","Romano"]],
	"Japan": [["Haruto","Ren","Yuto","Sota","Minato","Kaito"], ["Himari","Yui","Aoi","Sakura","Hina","Mei"], ["Sato","Suzuki","Takahashi","Tanaka","Watanabe","Ito"]],
	"Mexico": [["Santiago","Mateo","Sebastián","Diego","Emiliano","Daniel"], ["Valentina","Ximena","Regina","Camila","Sofía","Mariana"], ["Hernández","García","Martínez","López","González","Pérez"]],
	"Netherlands": [["Noah","Daan","Finn","Sem","Lucas","Levi"], ["Emma","Julia","Sophie","Mila","Tess","Zoë"], ["Visser","Smit","Meijer","Bakker","Mulder","Bos"]],
	"Norway": [["Jakob","Emil","Noah","Oliver","Filip","Magnus"], ["Nora","Emma","Ella","Olivia","Ingrid","Sofie"], ["Hansen","Johansen","Olsen","Larsen","Andersen","Nilsen"]],
	"Portugal": [["Francisco","João","Afonso","Tomás","Duarte","Miguel"], ["Maria","Leonor","Matilde","Carolina","Beatriz","Inês"], ["Silva","Santos","Ferreira","Pereira","Oliveira","Costa"]],
	"Russia": [["Aleksandr","Dmitri","Ivan","Mikhail","Nikolai","Sergei"], ["Anastasia","Daria","Ekaterina","Irina","Maria","Olga"], ["Ivanov","Petrov","Smirnov","Sokolov","Volkov","Kuznetsov"]],
	"Singapore": [["Ryan","Ethan","Lucas","Aiden","Zhiwei","Junjie"], ["Chloe","Megan","Ashley","Xinyi","Jiawen","Yuting"], ["Tan","Lim","Lee","Ng","Ong","Goh"]],
	"South Africa": [["Sipho","Thabo","Themba","Lwazi","Sibusiso","Bongani"], ["Nomsa","Zanele","Lerato","Naledi","Thandi","Ayanda"], ["Nkosi","Dlamini","Khumalo","Mokoena","Ndlovu","Mabena"]],
	"South Korea": [["Minjun","Seojun","Jiho","Juwon","Doyun","Hyunwoo"], ["Seoyeon","Jiwoo","Seohyun","Haeun","Jiyu","Yejin"], ["Kim","Lee","Park","Choi","Jung","Kang"]],
	"Spain": [["Hugo","Martín","Mateo","Pablo","Lucas","Álvaro"], ["Lucía","Sofía","Martina","María","Paula","Daniela"], ["García","Rodríguez","González","Fernández","López","Sánchez"]],
	"Sweden": [["William","Lucas","Liam","Oscar","Hugo","Elias"], ["Alice","Maja","Elsa","Astrid","Wilma","Freja"], ["Andersson","Johansson","Karlsson","Nilsson","Eriksson","Larsson"]],
	"Switzerland": [["Noah","Liam","Matteo","Luca","Leon","Elias"], ["Mia","Emma","Sofia","Lena","Lina","Emilia"], ["Müller","Meier","Schmid","Keller","Weber","Huber"]],
	"United Kingdom": [["Oliver","George","Harry","Arthur","Charlie","Oscar"], ["Olivia","Amelia","Isla","Ava","Freya","Florence"], ["Smith","Jones","Taylor","Brown","Wilson","Davies"]],
	"United States": [["Liam","Noah","James","Elijah","Henry","Benjamin"], ["Olivia","Emma","Charlotte","Amelia","Sophia","Isabella"], ["Smith","Johnson","Williams","Brown","Davis","Miller"]],
	"Belgium": [["Lucas","Louis","Arthur","Noah","Jules","Victor"], ["Emma","Olivia","Louise","Alice","Camille","Mila"], ["Peeters","Janssens","Maes","Jacobs","Mertens","Willems"]],
	"Chile": [["Mateo","Agustín","Santiago","Tomás","Lucas","Benjamín"], ["Sofía","Emilia","Florencia","Isidora","Martina","Catalina"], ["González","Muñoz","Rojas","Díaz","Pérez","Soto"]],
	"Colombia": [["Santiago","Sebastián","Matías","Samuel","Jerónimo","Emiliano"], ["Luciana","Salomé","Isabella","Mariana","Gabriela","Valentina"], ["Rodríguez","Gómez","González","Martínez","García","López"]],
	"Egypt": [["Ahmed","Mohamed","Mahmoud","Youssef","Aly","Mostafa"], ["Fatma","Mariam","Aya","Nour","Salma","Farida"], ["El-Sayed","Hassan","Ali","Ibrahim","Abdelrahman","Kamel"]],
	"Finland": [["Eetu","Onni","Aleksi","Leo","Elias","Oliver"], ["Aino","Emma","Sofia","Helmi","Ella","Venla"], ["Korhonen","Virtanen","Mäkinen","Nieminen","Mäkelä","Hämäläinen"]],
	"Greece": [["Dimitris","Nikolaos","Konstantinos","Giorgos","Ioannis","Alexandros"], ["Maria","Eleni","Aikaterini","Vasiliki","Sofia","Georgia"], ["Papadopoulos","Oikonomou","Georgiou","Nikolaou","Dimitriou","Papageorgiou"]],
	"New Zealand": [["Oliver","Jack","Noah","Leo","Lucas","Liam"], ["Charlotte","Amelia","Isla","Olivia","Harper","Sophie"], ["Smith","Jones","Williams","Brown","Wilson","Taylor"]],
	"Nigeria": [["Chinedu","Emeka","Oluwaseun","Babajide","Ifeanyi","Tunde"], ["Ngozi","Chioma","Amina","Zainab","Folake","Blessing"], ["Okafor","Adeyemi","Balogun","Eze","Ibrahim","Okeke"]],
	"Philippines": [["Joshua","Daniel","John","Gabriel","Angelo","Mark"], ["Althea","Angel","Bea","Princess","Jasmine","Sophia"], ["Santos","Reyes","Cruz","Bautista","Ocampo","Garcia"]],
	"Poland": [["Jakub","Jan","Antoni","Filip","Szymon","Aleksander"], ["Zuzanna","Julia","Maja","Hanna","Lena","Alicja"], ["Nowak","Kowalski","Wiśniewski","Wójcik","Kowalczyk","Kamiński"]],
	"Saudi Arabia": [["Mohammed","Omar","Fahd","Abdullah","Saud","Khalid"], ["Fatima","Noura","Sara","Reem","Haya","Layan"], ["Al-Ghamdi","Al-Zahrani","Al-Shehri","Al-Otaibi","Al-Harbi","Al-Dossari"]],
	"Taiwan": [["Yu-Ting","Chia-Hao","Kuan-Yu","Po-Chun","Chien-Hung","Chih-Wei"], ["Ting-Yu","Ya-Ting","Shu-Fen","Hsin-Yi","Pei-Shan","Li-Hua"], ["Chen","Lin","Huang","Chang","Li","Wang"]],
	"Thailand": [["Somchai","Arthit","Kittisak","Nattawut","Thanawat","Chai"], ["Malee","Siriporn","Kanya","Apinya","Supaporn","Sunee"], ["Saetang","Sukprasert","Saelim","Rattanakosin","Wongsuwan","Suksawat"]],
	"Turkey": [["Yusuf","Mustafa","Ahmet","Mehmet","Ali","Emir"], ["Zeynep","Elif","Defne","Asra","Azra","Ecrin"], ["Yılmaz","Kaya","Demir","Çelik","Şahin","Yıldız"]],
	"Ukraine": [["Artem","Maksym","Oleksandr","Dmytro","Vladyslav","Ivan"], ["Anastasiya","Sofia","Anna","Maria","Viktoriya","Daryna"], ["Melnyk","Shevchenko","Boyko","Kovalenko","Bondarenko","Tkachenko"]],
	"Vietnam": [["Minh","Duc","Anh","Huy","Nam","Tuan"], ["Linh","Mai","Huong","Trang","Lan","Ngoc"], ["Nguyen","Tran","Le","Pham","Hoang","Vu"]],
}

static func random_name(country: String, female: bool) -> String:
	var pool: Array = POOLS.get(country, POOLS["United States"])
	var given: String = pool[1 if female else 0].pick_random()
	var family: String = pool[2].pick_random()
	if country == "Russia" and female:
		family += "a"
	return given + " " + family


static func random_first_name(country: String, female: bool) -> String:
	var pool: Array = POOLS.get(country, POOLS["United States"])
	return str(pool[1 if female else 0].pick_random())

