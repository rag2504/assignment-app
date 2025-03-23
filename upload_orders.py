import csv
import requests

api_url = "https://66d56529f5859a704265e791.mockapi.io/orders"
csv_file_path = "INSTA  - INCOME (1).csv"

def read_csv(file_path):
    orders = []
    with open(file_path, mode='r', encoding='utf-8-sig') as file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            # Ensure header keys are stripped of whitespace
            order = {
                "date": row["Date"].strip() if "Date" in row else "",
                "submission_date": row["Submission Date"].strip() if "Submission Date" in row else "",
                "name": row["Name"].strip() if "Name" in row else "",
                "project": row["Project "].strip() if "Project " in row else "",
                "total": row["Paisa"].strip() if "Paisa" in row else "",
                "advance": row["Advance"].strip() if "Advance" in row else "",
                "after": row["After"].strip() if "After" in row else "",
                "person": row["with zeel/rag"].strip() if "with zeel/rag" in row else "",
                "payment_mode": row["Mode Of Payment "].strip() if "Mode Of Payment " in row else ""
            }
            orders.append(order)
    return orders

def send_orders_to_api(orders):
    for order in orders:
        response = requests.post(api_url, json=order)
        if response.status_code == 201:
            print(f"Successfully added order for {order['name']}")
        else:
            print(f"Failed to add order for {order['name']}. Status code: {response.status_code}")

if __name__ == "__main__":
    orders = read_csv(csv_file_path)
    send_orders_to_api(orders)