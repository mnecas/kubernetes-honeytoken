from flask import Flask, json, request

api = Flask(__name__)

@api.route('/', methods=['POST'])
def get_companies():
    print(request.data)

if __name__ == '__main__':
    api.run(host='192.168.0.111')
