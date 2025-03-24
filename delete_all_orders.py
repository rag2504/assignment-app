import requests

api_url = "https://66d56529f5859a704265e791.mockapi.io/orders"

def fetch_all_orders():
    response = requests.get(api_url)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Failed to fetch orders. Status code: {response.status_code}")
        print(f"Response content: {response.content}")
        return []

def delete_order(order_id):
    response = requests.delete(f"{api_url}/{order_id}")
    if response.status_code == 200:
        print(f"Successfully deleted order with ID {order_id}")
    else:
        print(f"Failed to delete order with ID {order_id}. Status code: {response.status_code}")
        print(f"Response content: {response.content}")

if __name__ == "__main__":
    orders = fetch_all_orders()
    for order in orders:
        delete_order(order["id"])