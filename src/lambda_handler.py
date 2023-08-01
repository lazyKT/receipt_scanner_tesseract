import re
import cv2
import pytesseract
from datetime import datetime



def extract (img_path) -> list():
    pytesseract.pytesseract.tesseract_cmd = r'C:\\Program Files\\Tesseract-OCR\\tesseract.exe'
    img = cv2.imread(img_path)
    return pytesseract.image_to_string(img).split('\n')


def current_datetime_ddmmYYYY():
    return datetime.strftime(datetime.now(), '%d-%m-%y')


def process_date (date_str_arr: list) -> str:
    if len(date_str_arr) < 1:
        return current_datetime_ddmmYYYY()
    date_str = date_str_arr[0]
    ddmmyyyy_pattern = r'\d\d[-|\s]\d\d[-|\s]\d\d\d\d'
    results = re.findall(ddmmyyyy_pattern, date_str)
    return results[0] if len(results) > 0 else current_datetime_ddmmYYYY()


def process_amount (amount_str_arr: list) -> str:
    if len(amount_str_arr) < 1:
        return '00.00'
    amount_str = amount_str_arr[0]
    amount_pattern = r'(?=.*?\d)\d*[.,]?\d*$'
    results = re.findall(amount_pattern, amount_str)
    return results[0] if len(results) > 0 else '00.00'


def transform (data: list()) -> dict:
    total_amount = list(filter(lambda x: 'AMOUNT' in x, data))
    dates = list(filter(lambda x: 'Date' in x, data))
    return {
        'total_amount': process_amount(total_amount),
        'date': process_date(dates)
    }


def lambda_handler (event, context):
    message = 'Hello {} !'.format(event['key1'])
    return {
        'message': message
    }


if __name__ == '__main__':
    img_path = 'test_images/receipt_1.jpg'
    lines = extract(img_path)
    obj = transform(lines)
    print(obj)
