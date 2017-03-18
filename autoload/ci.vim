if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

if !exists('g:ci_show_generalization')
    let g:ci_show_generalization = 0
endif

if !exists('g:ci_show_explains')
    let g:ci_show_explains = 1
endif

if !exists('g:ci_show_web')
    let g:ci_show_web = 0
endif

function! ci#GetCi()

python<<EOF
from __future__ import print_function
import sys
import vim
import json

try:
    from urllib2 import urlopen
except:
    from urllib.request import urlopen

try:
    from urllib import urlencode
except:
    from urllib.parse import urlencode

eprint = sys.stderr.write

url = r'''http://fanyi.youdao.com/openapi.do'''

data = {
    'keyfrom': 'hidict',
    'key': '1217482697',
    'type': 'data',
    'doctype': 'json',
    'version': '1.1',
}

def get_response(word):
    data['q'] = word 
    url_values = urlencode(data)
    full_url = url + '?' + url_values
    try:
        result = urlopen(full_url).read()
    except:
        eprint("ERROR: Can not make network connection")
        return None
    else:
        try:
            return json.loads(result, encoding='utf-8')
        except:
            eprint("ERROR: Can not translate %s" % word)
            return None

def is_valid_result(result):
    error_code = result.get('errorCode')
    if error_code == 0:
        return True
    else:
        eprint("ERROR: can't translate %s" % result.get("query"))
        return False

def show_generalization(result):
    translation = result.get('translation')
    if translation:
        print('Translation:')
        for t in translation:
            print('\t', t.encode('utf-8'))


def show_explains(result):
    basic = result.get('basic')
    if basic:
        explains = basic.get('explains')
        if explains:
            print('Explains:')
            for e in explains:
                print('\t', e.encode('utf-8'))

def show_web(result):
    web = result.get('web')
    if web:
        for item in web:
            print("Key: ", item.get('key').encode('utf-8'))
            for v in item.get('value'):
                print('\tvalue: ', v.encode('utf-8'))


esc = r''',./<>?:;'"{}[]|\~`!@#$%^&*()-_=+'''

word = vim.eval('expand("<cword>")').strip(esc)

print(word)

result = get_response(word)

if result and is_valid_result(result):
    if int(vim.eval('g:ci_show_generalization')):
        show_generalization(result)
    
    if int(vim.eval('g:ci_show_explains')):
        show_explains(result)
    
    if int(vim.eval('g:ci_show_web')):
        show_web(result)


EOF

endfunction

