import datetime
from faker import Faker
import random

class User:
    def __init__(self, name, surname, sex, join_date, phone_number, email, points_collected):
        self.name = name
        self.surname = surname
        self.sex = sex
        self.join_date = join_date
        self.phone_number = phone_number
        self.email = email
        self.points_collected = points_collected

    def generate(fake: Faker, points_collected: int = 0):
        gender = random.choice([0, 1, 2, 9])
        match(gender):
            case 1:
                name = fake.first_name_male()
            case 2:
                name = fake.first_name_female()
            case _:
                name = fake.first_name()
        surname = fake.last_name()
        return User(
            name,
            surname,
            gender,
            fake.date_time_this_century(),
            fake.phone_number().replace("-", "").replace(" ", ""),
            f"{name}.{surname}@{fake.free_email_domain()}".replace(" ", "").lower(),
            points_collected
        )

    def __str__(self):
        value = f"('{self.name}', '{self.surname}', '{self.sex}', '{self.join_date}', '{self.phone_number}', '{self.email}', {self.points_collected})"
        return value.replace("'NULL'", "NULL")

class Employee:
    def __init__(self, name, surname, sex, employment_date, leave_date, phone_number, email, role, shop_id):
        self.name = name
        self.surname = surname
        self.sex = sex
        self.employment_data = employment_date
        self.leave_date = leave_date
        self.phone_number = phone_number
        self.email = email
        self.role = role
        self.shop_id = shop_id

    def generate(fake: Faker, shops_count: int, leave_probability: float):
        gender = random.choice([0, 1, 2, 9])
        match(gender):
            case 1:
                name = fake.first_name_male()
            case 2:
                name = fake.first_name_female()
            case _:
                name = fake.first_name()
        surname = fake.last_name()
        employment_date = fake.date_time_this_century()

        return Employee(
            name,
            surname,
            gender,
            employment_date,
            random.random() < leave_probability and fake.date_time_between(employment_date) or 'NULL',
            fake.phone_number().replace("-", "").replace(" ", ""),
            f"{name}.{surname}@{fake.free_email_domain()}".replace(" ", "").lower(),
            random.choice(['Menedżer', 'Asystant', 'Sprzedawca', 'Magazynier']),
            random.randint(1, shops_count)
        )

    def __str__(self):
        value = f"('{self.name}', '{self.surname}', '{self.sex}', '{self.employment_data}', '{self.leave_date}', '{self.phone_number}', '{self.email}', '{self.role}', '{self.shop_id}')"
        return value.replace("'NULL'", "NULL")

class Shop:
    def __init__(self, name, country, city, address, post_code, open_date, close_date):
        self.name = name
        self.country = country
        self.city = city
        self.address = address
        self.post_code = post_code
        self.open_date = open_date
        self.close_date = close_date

    def generate(fake: Faker, close_probability: float):
        open_date = fake.date_time_this_century()
        city = fake.city()
        return Shop(
            f'Sklep "Ropucha" {city}',
            "Polska",
            city,
            fake.street_address(),
            fake.postcode(),
            open_date,
            random.random() < close_probability and fake.date_time_between(open_date) or 'NULL'
        )
    
    def __str__(self):
        value = f"('{self.name}', '{self.country}', '{self.city}', '{self.address}', '{self.post_code}', '{self.open_date}', '{self.close_date}')"
        return value.replace("'NULL'", "NULL")
    
class Brand:
    def __init__(self, name, country):
        self.name = name
        self.country = country

    def generate(fake: Faker):
        return Brand(
            fake.company(),
            "Polska"
        )
    
    def __str__(self):
        value = f"('{self.name}', '{self.country}')"
        return value.replace("'NULL'", "NULL")

class Manufacturer:
    def __init__(self, name, country, speciality):
        self.name = name
        self.country = country
        self.speciality = speciality


    def generate(fake: Faker):
        specialities = ['Produkcja', 'Dystrybucja', 'Transport', 'Zasoby', 'R&D', 'Usługi', 'Handel', 'Inne']
        return Manufacturer(
            fake.company(),
            "Polska",
            random.choice(specialities)
        )
    
    def __str__(self):
        value = f"('{self.name}', '{self.country}', '{self.speciality}')"
        return value.replace("'NULL'", "NULL")

class Product_manufacturer:
    def __init__(self, product_id, manufacturer_id):
        self.product_id = product_id
        self.manufacturer_id = manufacturer_id

    def generate(product_id: int, manufacturer_id: int):
        return Product_manufacturer(
            product_id,
            manufacturer_id
        )
    
    def __str__(self):
        value = f"('{self.product_id}', '{self.manufacturer_id}')"
        return value.replace("'NULL'", "NULL")

class Storage:
    def __init__(self, shop_id, product_id, amount):
        self.shop_id = shop_id
        self.product_id = product_id
        self.amount = amount

    def generate(shop_id: int, product_id: int, zero_prodocuts_probability: float):
        if(random.random() < zero_prodocuts_probability):
            amount = 0
        else:
            amount = random.randint(0, 100)
        return Storage(
            shop_id,
            product_id,
            amount
        )
    
    def __str__(self):
        value = f"('{self.shop_id}', '{self.product_id}', '{self.amount}')"
        return value.replace("'NULL'", "NULL")
    
class Price_history:
    def __init__(self, price, start_date, product_id):
        self.price = price
        self.start_date = start_date
        self.product_id = product_id

    def generate(fake: Faker, product_id: int, expensive: bool, start_date: datetime.datetime, end_date: datetime.datetime):
        return Price_history(
            random.randint(10, 100)-0.01 if expensive else random.randint(1, 10)-0.01,
            fake.date_time_between(start_date, end_date),
            product_id
        )

    def __str__(self):
        value = f"({self.price}, '{self.start_date:%Y-%m-%d %H:%M:%S}', '{self.product_id}')"
        return value.replace("'NULL'", "NULL")
        

class Sale:
    def __init__(self, sale_date, total_cost, points_collected, client_id, employee_id):
        self.sale_date = sale_date
        self.total_cost = total_cost
        self.points_collected = points_collected
        self.client_id = client_id
        self.employee_id = employee_id

    def generate(fake: Faker, sale_date, client_count: int, employee_count: int, anonymous_probability: float, total_cost: float, points_collected: int):
        is_anonymous = random.random() < anonymous_probability
        if(is_anonymous):
            points_collected = 0
        return Sale(
            sale_date,
            total_cost,
            points_collected,
            is_anonymous and 'NULL' or random.randint(1, client_count),
            random.randint(1, employee_count)
        )
    
    def __str__(self):
        value = f"('{self.sale_date}', {round(self.total_cost, 2)}, {self.points_collected}, '{self.client_id}', '{self.employee_id}')"
        return value.replace("'NULL'", "NULL")
    
class Sale_detail:
    def __init__(self, sale_id, product_id, amount):
        self.sale_id = sale_id
        self.product_id = product_id
        self.amount = amount

    def generate(sale_id: int, product_id: int, amount: int):
        return Sale_detail(
            sale_id,
            product_id,
            amount
        )
    
    def __str__(self):
        value = f"('{self.sale_id}', '{self.product_id}', '{round(self.amount, 2)}')"
        return value.replace("'NULL'", "NULL")
        

def main():
    clients_count = 30

    employees_count = 20
    leave_probability = 0.2

    shops_count = 10
    close_probability = 0.1

    brands_count = 20

    manufacturers_count = 20

    products_count = 30
    zero_prodocuts_probability = 0.1

    max_products_per_manufacturer = 5

    max_price_history_per_product = 5
    expensive_products_ids = [25, 26, 27, 28, 29, 30]

    sales_count = 100
    max_products_per_sale = 10
    max_amount_per_product = 10
    anonymous_sales_probability = 0.5
    sales_details = []
    sales = []

    points_collected = [0 for _ in range(clients_count)]
    price_histories = [[] for _ in range(products_count)]

    seed = 0
    fake = Faker("pl_PL")
    fake.seed_instance(seed)
    random.seed(seed)

    with open("employees.txt", "w", encoding="UTF-8") as employees_file:
        for _ in range(employees_count):
            employee = Employee.generate(fake, shops_count, leave_probability)
            employees_file.write(str(employee) + ",\n")

    with open("shops.txt", "w", encoding="UTF-8") as shops_file:
        for _ in range(shops_count):
            shop = Shop.generate(fake, close_probability)
            shops_file.write(str(shop) + ",\n")

    with open("brands.txt", "w", encoding="UTF-8") as brands_file:
        for _ in range(brands_count):
            brand = Brand.generate(fake)
            brands_file.write(str(brand) + ",\n")
    
    with open("manufacturers.txt", "w", encoding="UTF-8") as manufacturers_file:
        for _ in range(manufacturers_count):
            manufacturer = Manufacturer.generate(fake)
            manufacturers_file.write(str(manufacturer) + ",\n")

    with open("storages.txt", "w", encoding="UTF-8") as storages_file:
        for shop_id in range(shops_count):
            for product_id in range(products_count):
                storage = Storage.generate(shop_id+1, product_id+1, zero_prodocuts_probability)
                storages_file.write(str(storage) + ",\n")

    with open("products_manufacturers.txt", "w", encoding="UTF-8") as products_manufacturers_file:
        for product_id in range(products_count):
            for i in range(random.randint(1, max_products_per_manufacturer)):
                products_manufacturers_file.write(str(Product_manufacturer.generate(product_id+1, random.randint(1, manufacturers_count))) + ",\n")

    with open("price_histories.txt", "w", encoding="UTF-8") as price_history_file:
        queue = []
        last_date = datetime.datetime(2000, 1, 1)

        for product_id in range(1, products_count+1):
            price_history = Price_history.generate(fake, product_id, product_id in expensive_products_ids, last_date, last_date)
            price_history_file.write(str(price_history) + ",\n")
            price_histories[product_id-1].append(price_history)


        for product_id in range(1, products_count+1):
            for _ in range(random.randint(1, max_price_history_per_product-1)):
                queue.insert(random.randint(0, len(queue)), product_id)

        for product_id in queue:
            price_history = Price_history.generate(fake, product_id, product_id in expensive_products_ids, last_date, last_date + datetime.timedelta(days=random.randint(1, 500)))
            price_history_file.write(str(price_history) + ",\n")
            price_histories[product_id-1].append(price_history)
            last_date = price_history.start_date

    # generate sale history
    last_date = fake.date_time_between(datetime.datetime(2000, 1, 2), datetime.datetime(2001, 1, 1))

    for sale_id in range(1, sales_count+1):
        sale_products_count = random.randint(1, max_products_per_sale)
        products = random.sample(range(1, products_count+1), sale_products_count)
        amounts = [random.randint(1, max_amount_per_product) for _ in range(sale_products_count)]
        prices = []
        for product_id in products:
            price = 0
            for price_history in price_histories[product_id-1]:
                if price_history.start_date <= last_date:
                    price = price_history.price
                else:
                    break
            prices.append(price)
        total_cost = sum([amount * price for amount, price in zip(amounts, prices)])
        points_for_sale = int(total_cost * 0.1)
        sale = Sale.generate(fake, last_date, clients_count, employees_count, anonymous_sales_probability, total_cost, points_for_sale)
        sales.append(sale)
        if(not sale.client_id == 'NULL'):
            points_collected[sale.client_id-1] += points_for_sale
        for product_id, amount in zip(products, amounts):
            sales_details.append(Sale_detail(sale_id, product_id, amount))
        last_date = fake.date_time_between(last_date, last_date + datetime.timedelta(days=random.randint(1, 330)))

    
    with open("clients.txt", "w", encoding="UTF-8") as clients_file:
        for user_id in range(clients_count):
            user = User.generate(fake, points_collected[user_id])
            clients_file.write(str(user) + ",\n")

    with open("sales.txt", "w", encoding="UTF-8") as sales_file:
        for sale in sales:
            sales_file.write(str(sale) + ",\n")

    with open("sales_details.txt", "w", encoding="UTF-8") as sales_details_file:
        for sale_detail in sales_details:
            sales_details_file.write(str(sale_detail) + ",\n")

    

if __name__ == "__main__":
    main()