import csv
import requests

api_url = "https://66d56529f5859a704265e791.mockapi.io/orders"
csv_file_path = "apiSheets.csv"

def read_csv(file_path):
    orders = []
    with open(file_path, mode='r', encoding='utf-8-sig') as file:
        csv_reader = csv.reader(file)
        headers = next(csv_reader, None)  # Skip header row
        if headers:
            for row in csv_reader:
                # Skip rows that do not have enough columns
                if len(row) < 10:
                    print(f"Skipping invalid row: {row}")
                    continue
                
                # Create order dictionary
                order = {
                    "orderDate": row[0].strip(),
                    "dueDate": row[1].strip(),
                    "customerName": row[2].strip(),
                    "projectType": row[3].strip(),
                    "totalAmount": row[4].strip(),
                    "advancePaid": row[5].strip(),
                    "balanceAmount": row[6].strip(),
                    "receivedBy": row[7].strip(),
                    "paymentMode": row[8].strip(),
                    "customerContact": row[9].strip() if len(row) > 9 else "",
                    "writerAssigned": row[10].strip() if len(row) > 10 else "",
                    "pages": row[11].strip() if len(row) > 11 else "",
                    "isCompleted": row[12].strip() if len(row) > 12 else ""
                }
                # Log the order being read
                print(f"Read order: {order}")
                orders.append(order)
    return orders

def send_orders_to_api(orders):
    for order in orders:
        print(f"Sending order: {order}")  # Log the order being sent
        response = requests.post(api_url, json=order)
        if response.status_code == 201:
            print(f"Successfully added order for {order['customerName']}")
        else:
            print(f"Failed to add order for {order['customerName']}. Status code: {response.status_code}")
            print(f"Response content: {response.content}")
            print(f"Data sent: {order}")

if __name__ == "__main__":
    orders = read_csv(csv_file_path)
    send_orders_to_api(orders)