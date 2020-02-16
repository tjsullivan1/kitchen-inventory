import os


def item_add(item_name: str = None, item_quantity: int = None, item_unit: str = None,
             item_date_added=None, item_category=None):
    """
    :param item_name:
    :param item_quantity:
    :param item_unit:
    :param item_date_added:
    :param item_category
    :return:
    """

    item_dict = {
        'name': item_name,
        'category': item_category,
        'amount': item_quantity,
        'unit': item_unit,
        'date_added': item_date_added
    }

    return item_dict


def connect_to_cosmos(endpoint, key):
    from azure.cosmos.cosmos_client import CosmosClient

    # Initialize the Cosmos client
    auth = {'masterKey': key}

    client = CosmosClient(endpoint, auth)

    return client


def get_container_link(client, db, container):
    from azure.cosmos.database import Database
    database = Database(client, db)
    container = database.get_container(container)

    return container.container_link


def create_item_in_cosmos(client, container_link, document):
    client.CreateItem(database_or_Container_link=container_link, document=document)
    pass


if __name__ == '__main__':
    endpoint = os.environ.get('COSMOS_ENDPOINT')
    key = os.environ.get('COSMOS_KEY')
    database_name = 'pantry'
    container_name = 'items'
    document = {"test": "item-new-func-3"}

    cxn = connect_to_cosmos(endpoint, key)
    link = get_container_link(cxn, database_name, container_name)
    create_item_in_cosmos(cxn, link, document)
    print(item_add(3, 2, 'T', 'now'))
