#!/bin/sh

# encrypt.sh

# 1. install ffmpeg and nodejs

# 2. run this shell-script in current github-repo
#    $ /bin/sh ./encrypt.sh

# 3. thats it!

shCryptoAesXxxCbcRawDecrypt () {(set -e
# this function will inplace aes-xxx-cbc decrypt stdin with the given hex-key $1
# example usage:
# printf 'hello world\n' | shCryptoAesXxxCbcRawEncrypt 0123456789abcdef0123456789abcdef | shCryptoAesXxxCbcRawDecrypt 0123456789abcdef0123456789abcdef
    node -e "
// <script>
/* jslint-utility2 */
/*jslint
    bitwise: true,
    browser: true,
    maxerr: 4,
    maxlen: 100,
    node: true,
    nomen: true,
    regexp: true,
    stupid: true
*/
'use strict';
var local, chunkList;
local = local || {};
(function () {
    (function () {
        local.base64ToBuffer = function (b64, mode) {
        /*
         * this function will convert b64 to Uint8Array
         * https://gist.github.com/wang-bin/7332335
         */
            /*globals Uint8Array*/
            var bff, byte, chr, ii, jj, map64, mod4;
            b64 = b64 || '';
            bff = new Uint8Array(b64.length); // 3/4
            byte = 0;
            jj = 0;
            map64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
            mod4 = 0;
            for (ii = 0; ii < b64.length; ii += 1) {
                chr = map64.indexOf(b64[ii]);
                if (chr >= 0) {
                    mod4 %= 4;
                    if (mod4 === 0) {
                        byte = chr;
                    } else {
                        byte = byte * 64 + chr;
                        bff[jj] = 255 & (byte >> ((-2 * (mod4 + 1)) & 6));
                        jj += 1;
                    }
                    mod4 += 1;
                }
            }
            // optimization - create resized-view of bff
            bff = bff.subarray(0, jj);
            // mode !== 'string'
            if (mode !== 'string') {
                return bff;
            }
            // mode === 'string' - browser js-env
            if (typeof window === 'object' && window && typeof window.TextDecoder === 'function') {
                return new window.TextDecoder().decode(bff);
            }
            // mode === 'string' - node js-env
            Object.setPrototypeOf(bff, Buffer.prototype);
            return String(bff);
        };
        local.cryptoAesXxxCbcRawDecrypt = function (options, onError) {
        /*
         * this function will aes-xxx-cbc decrypt with the given options
         * example usage:
            data = new Uint8Array([1,2,3]);
            key = '0123456789abcdef0123456789abcdef';
            mode = null;
            local.cryptoAesXxxCbcRawEncrypt({ data: data, key: key, mode: mode }, function (
                error,
                data
            ) {
                console.assert(!error, error);
                local.cryptoAesXxxCbcRawDecrypt({ data: data, key: key, mode: mode }, console.log);
            });
         */
            /*globals Uint8Array*/
            var cipher, crypto, data, ii, iv, key;
            // init key
            key = new Uint8Array(0.5 * options.key.length);
            for (ii = 0; ii < key.byteLength; ii += 2) {
                key[ii] = parseInt(options.key.slice(2 * ii, 2 * ii + 2), 16);
            }
            data = options.data;
            // base64
            if (options.mode === 'base64') {
                data = local.base64ToBuffer(data);
            }
            // normalize data
            if (!(data instanceof Uint8Array)) {
                data = new Uint8Array(data);
            }
            // init iv
            iv = data.subarray(0, 16);
            // optimization - create resized-view of data
            data = data.subarray(16);
            crypto = typeof window === 'object' && window.crypto;
            if (!(crypto && crypto.subtle && typeof crypto.subtle.importKey === 'function')) {
                setTimeout(function () {
                    crypto = require('crypto');
                    cipher = crypto.createDecipheriv(
                        'aes-' + (8 * key.byteLength) + '-cbc',
                        key,
                        iv
                    );
                    onError(null, Buffer.concat([cipher.update(data), cipher.final()]));
                });
                return;
            }
            crypto.subtle.importKey('raw', key, {
                name: 'AES-CBC'
            }, false, ['decrypt']).then(function (key) {
                crypto.subtle.decrypt({ iv: iv, name: 'AES-CBC' }, key, data).then(function (data) {
                    onError(null, new Uint8Array(data));
                }).catch(onError);
            }).catch(onError);
        };
    }());
}());
chunkList = [];
process.stdin.on('data', function (chunk) {
    chunkList.push(chunk);
});
process.stdin.on('end', function () {
    local.cryptoAesXxxCbcRawDecrypt({
        data: process.argv[2] === 'base64'
            ? Buffer.concat(chunkList).toString()
            : Buffer.concat(chunkList),
        key: process.argv[1],
        mode: process.argv[2]
    }, function (error, data) {
        if (error) {
            throw error;
        }
        Object.setPrototypeOf(data, Buffer.prototype);
        process.stdout.write(data);
    });
});
// </script>
" "$@"
)}

shCryptoAesXxxCbcRawEncrypt () {(set -e
# this function will inplace aes-xxx-cbc encrypt stdin with the given hex-key $1
# example usage:
# printf 'hello world\n' | shCryptoAesXxxCbcRawEncrypt 0123456789abcdef0123456789abcdef | shCryptoAesXxxCbcRawDecrypt 0123456789abcdef0123456789abcdef
    node -e "
// <script>
/* jslint-utility2 */
/*jslint
    bitwise: true,
    browser: true,
    maxerr: 4,
    maxlen: 100,
    node: true,
    nomen: true,
    regexp: true,
    stupid: true
*/
'use strict';
var local, chunkList;
local = local || {};
(function () {
    (function () {
        local.base64FromBuffer = function (bff, mode) {
        /*
         * this function will convert Uint8Array bff to base64
         * https://developer.mozilla.org/en-US/Add-ons/Code_snippets/StringView#The_code
         */
            var ii, mod3, text, uint24, uint6ToB64;
            // convert utf8-string bff to Uint8Array
            if (bff && mode === 'string') {
                bff = typeof window === 'object' &&
                    window &&
                    typeof window.TextEncoder === 'function'
                    ? new window.TextEncoder().encode(bff)
                    : Buffer.from(bff);
            }
            bff = bff || [];
            text = '';
            uint24 = 0;
            uint6ToB64 = function (uint6) {
                return uint6 < 26
                    ? uint6 + 65
                    : uint6 < 52
                    ? uint6 + 71
                    : uint6 < 62
                    ? uint6 - 4
                    : uint6 === 62
                    ? 43
                    : 47;
            };
            for (ii = 0; ii < bff.length; ii += 1) {
                mod3 = ii % 3;
                uint24 |= bff[ii] << (16 >>> mod3 & 24);
                if (mod3 === 2 || bff.length - ii === 1) {
                    text += String.fromCharCode(
                        uint6ToB64(uint24 >>> 18 & 63),
                        uint6ToB64(uint24 >>> 12 & 63),
                        uint6ToB64(uint24 >>> 6 & 63),
                        uint6ToB64(uint24 & 63)
                    );
                    uint24 = 0;
                }
            }
            return text.replace(/A(?=A$|$)/g, '=');
        };
        local.cryptoAesXxxCbcRawEncrypt = function (options, onError) {
        /*
         * this function will aes-xxx-cbc encrypt with the given options
         * example usage:
            data = new Uint8Array([1,2,3]);
            key = '0123456789abcdef0123456789abcdef';
            mode = null;
            local.cryptoAesXxxCbcRawEncrypt({ data: data, key: key, mode: mode }, function (
                error,
                data
            ) {
                console.assert(!error, error);
                local.cryptoAesXxxCbcRawDecrypt({ data: data, key: key, mode: mode }, console.log);
            });
         */
            /*globals Uint8Array*/
            var cipher, crypto, data, ii, iv, key;
            // init key
            key = new Uint8Array(0.5 * options.key.length);
            for (ii = 0; ii < key.byteLength; ii += 2) {
                key[ii] = parseInt(options.key.slice(2 * ii, 2 * ii + 2), 16);
            }
            data = options.data;
            // init iv
            iv = new Uint8Array((((data.byteLength) >> 4) << 4) + 32);
            crypto = typeof window === 'object' && window.crypto;
            if (!(crypto && crypto.subtle && typeof crypto.subtle.importKey === 'function')) {
                setTimeout(function () {
                    crypto = require('crypto');
                    // init iv
                    iv.set(crypto.randomBytes(16));
                    cipher = crypto.createCipheriv(
                        'aes-' + (8 * key.byteLength) + '-cbc',
                        key,
                        iv.subarray(0, 16)
                    );
                    data = cipher.update(data);
                    iv.set(data, 16);
                    iv.set(cipher.final(), 16 + data.byteLength);
                    if (options.mode === 'base64') {
                        iv = local.base64FromBuffer(iv);
                        iv += '\n';
                    }
                    onError(null, iv);
                });
                return;
            }
            // init iv
            iv.set(crypto.getRandomValues(new Uint8Array(16)));
            crypto.subtle.importKey('raw', key, {
                name: 'AES-CBC'
            }, false, ['encrypt']).then(function (key) {
                crypto.subtle.encrypt({
                    iv: iv.subarray(0, 16),
                    name: 'AES-CBC'
                }, key, data).then(function (data) {
                    iv.set(new Uint8Array(data), 16);
                    // base64
                    if (options.mode === 'base64') {
                        iv = local.base64FromBuffer(iv);
                        iv += '\n';
                    }
                    onError(null, iv);
                }).catch(onError);
            }).catch(onError);
        };
    }());
}());
chunkList = [];
process.stdin.on('data', function (chunk) {
    chunkList.push(chunk);
});
process.stdin.on('end', function () {
    local.cryptoAesXxxCbcRawEncrypt({
        data: Buffer.concat(chunkList),
        key: process.argv[1],
        mode: process.argv[2]
    }, function (error, data) {
        if (error) {
            throw error;
        }
        Object.setPrototypeOf(data, Buffer.prototype);
        process.stdout.write(data);
    });
});
// </script>
" "$@"
)}

ffmpeg \
    -i big_buck_bunny_480p_trailer.m4v \
    -c:v copy \
    -c:a copy \
    -hls_list_size 0 \
    -hls_time 6 \
    -hls_segment_filename hls.%04d.ts \
    -y \
    hls.m3u8
cat hls.m3u8.crypto | shCryptoAesXxxCbcRawEncrypt 0123456789abcdef0123456789abcdef base64 > hls.m3u8.encrypted
cat hls.m3u8.encrypted | shCryptoAesXxxCbcRawDecrypt 0123456789abcdef0123456789abcdef base64
echo "encrypted file hls.m3u8.crypto -> hls.m3u8.encrypted"
for II in 0 1 2 3 4 5
do
    cat "hls.000$II.ts" | shCryptoAesXxxCbcRawEncrypt 0123456789abcdef0123456789abcdef > "hls.000$II.ts.encrypted"
    echo "encrypted file hls.000$II.ts -> hls.000$II.ts"
done
