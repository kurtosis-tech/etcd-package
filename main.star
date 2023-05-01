NAME_ARG = "etcd_name"
NAME_ARG_DEFAULT = "etcd"

IMAGE_ARG = "etcd_image"
IMAGE_ARG_DEFAULT = "softlang/etcd-alpine:v3.4.14"

CLIENT_PORT_ARG = "etcd_client_port"
CLIENT_PORT_ARG_DEFAULT = 2379

ENV_VARS_ARG = "etcd_env_vars"
ENV_VARS_ARG_DEFAULT = {}

def run(plan, args):

    name = args.get(NAME_ARG, NAME_ARG_DEFAULT)
    image = args.get(IMAGE_ARG, IMAGE_ARG_DEFAULT)
    client_port = args.get(CLIENT_PORT_ARG, CLIENT_PORT_ARG_DEFAULT)
    env_vars_overrides = args.get(ENV_VARS_ARG, ENV_VARS_ARG_DEFAULT)
    env_vars = {
        "ALLOW_NONE_AUTHENTICATION": "yes",
        "ETCD_DATA_DIR": "/etcd_data",
        "ETCD_LISTEN_CLIENT_URLS": "http://0.0.0.0:{}".format(client_port),
        "ETCD_ADVERTISE_CLIENT_URLS": "http://0.0.0.0:{}".format(client_port),
    } | env_vars_overrides

    etcd_service_config= ServiceConfig(
        image = image,
        ports = {
            "client": PortSpec(number = client_port, transport_protocol = "TCP")
        },
        env_vars = env_vars,
        ready_conditions = ReadyCondition(
            recipe = ExecRecipe(
                command = ["etcdctl", "get", "test"]
            ),
            field = "code",
            assertion = "==",
            target_value = 0
        )
    )

    etcd = plan.add_service(name = name, config = etcd_service_config)

    return {"service-name": name, "hostname": etcd.hostname, "port": client_port}

