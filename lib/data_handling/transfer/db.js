import { response } from 'wix-http-functions';
import wixData from 'wix-data';
import { getSecret } from 'wix-secrets-backend';
const crypto = require("crypto");
// https://infinitumlabsinc.editorx.io/lighthousecloud/_functions/getById

const encoding = 'hex';
// Key bytes length depends on algorithm being used:
// 'aes-128-gcm' = 16 bytes
// 'aes-192-gcm' = 24 bytes
// 'aes-256-gcm' = 32 bytes
// const key = Buffer.from("7033733676397924423F4528482B4D62", 'hex');
const secret = async () => Buffer.from(await getSecret('aes_secret'), 'hex');
const algo = 'aes-128-gcm';

const tables = [
    'bin',
    'users',
    'workbench',
    'goals',
    'projects',
    'epics',
    'sprints',
    'tasks',
    'events',
    'issues',
    'prototypes'
];

function options(origin) {
    return {
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": origin,
            "Access-Control-Allow-Credentials": true,
            "Authorization": null
        },
        "body": {
            "status": {
                "code": 200, // CHANGE TO 500 for production, 200 for debugging
                "msg": "Default response"
            },
            "payload": []
        }
    }
}

class Auth {
    static generateBody(userId) {
        let timeNow = Math.round(Date.now() / 1000);
        return {
            "headers": {
                "alg": algo,
                "typ": "JWT"
            },
            "payload": {
                "iat": timeNow,
                "exp": timeNow + 1200, // valid for 20 minutes
                "sub": userId
            }
        };
    }

    static hashBody(body) {
        return crypto.createHash('sha256').update(JSON.stringify(body)).digest(encoding);
    }

    static async encrypt(hexBody) {
        const iv = crypto.randomBytes(16);
        const cipher = crypto.createCipheriv(algo, await secret(), iv);
        const encrypted = Buffer.concat([
            cipher.update(Buffer.from(hexBody, 'hex')),
            cipher.final(),
        ]);
        const authTag = cipher.getAuthTag();
        return {
            encryptedData: encrypted.toString('hex'),
            iv: iv.toString('hex'),
            authTag: authTag.toString('hex')
        };
    }

    static async decrypt(encryptedHex, ivHex, authTagHex) {
        const decipher = crypto.createDecipheriv(algo, await secret(), Buffer.from(ivHex, 'hex'));
        decipher.setAuthTag(Buffer.from(authTagHex, 'hex'));

        const decryptedHex = Buffer.concat([
            decipher.update(Buffer.from(encryptedHex, 'hex')),
            decipher.final(),
        ]);

        return decryptedHex.toString('hex');
    }

    static async validateJWT(request, action) {
        let res = options(request.headers.origin);
        let reqBody = JSON.parse(await request.body.text());
        /* if (!('jwt' in reqBody && 'authorization' in request.headers)) {
            res.status = res.body.status.code = 401;
            res.body.status.msg = "JWT token has expired. Please login again.";
            return response(res);
        } */
        let body = reqBody['jwt']['body'];
        let signature = reqBody['jwt']['signature'];
        let hashedBody = Auth.hashBody(body);
        let decryptedBody = await Auth.decrypt(signature.encryptedData, signature.iv, signature.authTag);
        try {
            let isEqual = hashedBody == decryptedBody;
            let isValid = body['payload']['exp'] > Math.round(Date.now() / 1000);
            if (isEqual) {
                if (isValid) {
                    try {
                        return await action(reqBody, res);
                    } catch (err) {
                        console.log(err);
                        res.status = res.body.status.code = 500;
                        res.body.status.msg = err;
                        return response(res);
                    }
                } else {
                    res.status = res.body.status.code = 401;
                    res.body.status.msg = "JWT token has expired. Please login again.";
                    return response(res);
                }
            } else if (!isEqual) {
                res.status = res.body.status.code = 401;
                res.body.status.msg = "JWT payload hash does not match decrypted signature: JWT may have been tampered with. Service denied.";
                return response(res);
            } else {
                res.status = res.body.status.code = 500;
                res.body.status.msg = "JWT payload validation failed (null returned)";
                return response(res);
            }
        } catch (err) {
            console.log(err);
            res.status = res.body.status.code = 500;
            res.body.status.msg = err;
            return response(res);
        }
    }
}

function buildQuery(dataQuery, queryObject) {
    let filter = dataQuery;
    for (const f of queryObject) {
        switch (f.type) {
        case 'between':
            filter = filter.between(f.prop, f.rangeStart, f.rangeEnd);
            break;
        case 'contains':
            filter = filter.contains(f.prop, f.substring);
            break;
        case 'eq':
            filter = filter.eq(f.prop, f.value);
            break;
        case 'ne':
            filter = filter.ne(f.prop, f.value);
            break;
        case 'gt':
            filter = filter.gt(f.prop, f.value);
            break;
        case 'ge':
            filter = filter.ge(f.prop, f.value);
            break;
        case 'lt':
            filter = filter.lt(f.prop, f.value);
            break;
        case 'le':
            filter = filter.le(f.prop, f.value);
            break;
        case 'hasSome':
            filter = filter.hasSome(f.prop, f.values);
            break;
        }
    }
    return filter;
}

export async function use_getJwtToken(request) {
    let reqBody = JSON.parse(await request.body.text());
    let res = options(request.headers.origin);
    res.body.payload.length = 0;
    let result = await wixData.query("users")
        .contains("emailAddress", reqBody.emailAddress)
        .find();
    try {
        if (result.items.length == 0) {
            res.status = res.body.status.code = 404;
            res.body.status.msg = "No users with that email address";
            return response(res);
        } else {
            let item = result.items[0];
            if (reqBody.password == item['password']) {
                res.status = res.body.status.code = 200;
                res.body.status.msg = "OK";
                let body = Auth.generateBody(item['objectId']);
                let hashedBody = Auth.hashBody(body);
                let encryptedBody = await Auth.encrypt(hashedBody);
                res.body.payload.push({
                    'body': body,
                    'signature': encryptedBody,
                });
                return response(res);
            } else {
                res.status = res.body.status.code = 403;
                res.body.status.msg = "Incorrect password";
                return response(res);
            }
        }
    } catch (err) {
        console.log(err);
        res.status = res.body.status.code = 500;
        res.body.status.msg = err;
        return response(res);
    }
}

export async function use_val(request) {
    return await Auth.validateJWT(request, async (res) => {
        return response(res);
    });
}

export async function use_refreshJwtToken(request) {
    return await Auth.validateJWT(request, async (reqBody, res) => {
        let userId = JSON.parse(reqBody['jwt'])['body']['payload']['sub'];
        res.status = res.body.status.code = 200;
        res.body.status.msg = "OK";
        let body = Auth.generateBody(userId);
        let encryptedBody = await Auth.encrypt(Auth.hashBody(body));
        body.signature = encryptedBody;
        res.body.payload = [body];
        return response(res);

    });
}

export async function use_getAllObjects(request) {
    return await Auth.validateJWT(request, async (reqBody, res) => {
        const payload = {};
        let user = (await wixData.query('users').eq('objectId', reqBody.userId)
            .find()).items[0];
        let workbench = (await wixData.query('workbenches').eq('objectId', user['workbenchId'])
            .find()).items[0];
        payload['workbenches'] = [workbench];
        payload['users'] = [user];
        for (const table of tables) {
            if (Object.keys(workbench).includes(table)) {
                let objects = (await wixData.query(table).hasSome('objectId', workbench[table]).find()).items;
                payload[table] = objects;
            }
        }
        res.body.payload = [payload];
        return response(res);
    });
}

export async function use_testPost(request) {
    console.log(request);
    console.log(await request.body.json());
    console.log(JSON.parse(await request.body.text()));
    return response(options(request.headers.origin));
}

export async function use_getById(request) {
    return await Auth.validateJWT(request, async (reqBody, res) => {
        let result = await wixData.query(reqBody.collectionId)
            .eq('objectId', reqBody.objectId)
            .find();
        if (result.items.length == 0) {
            res.status = res.body.status.code = 404;
            res.body.status.msg = "No items in collection with a matching ID.";
            return response(res);
        } else {
            res.status = res.body.status.code = 200;
            res.body.status.msg = "OK";
            res.body.payload = result.items;
            return response(res);
        }

    });

}