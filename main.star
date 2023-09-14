def run(
    plan, 
    etcd_name="etcd",
    etcd_image="softlang/etcd-alpine:v3.4.14",
    etcd_client_port=2379,
    etcd_env_vars={},
):
    """Runs a single-node etcd cluster

    Args:
        etcd_name (string): The name of the etcd service in the enclave
        etcd_image (string): The container image to use
        etcd_client_port (int): The port on which etcd listens
        etcd_env_vars (dict[string, string]): Environment variables default overrides. Defaults are:
            ```
            {
                "ALLOW_NONE_AUTHENTICATION": "yes",
                "ETCD_DATA_DIR": "/etcd_data/",
                "ETCD_LISTEN_CLIENT_URLS": "http://0.0.0.0:<ETCD_CLIENT_PORT_PARAM>",
                "ETCD_ADVERTISE_CLIENT_URLS": "http://0.0.0.0:<ETCD_CLIENT_PORT_PARAM>",
            }
            ```
    Returns:
        Returns an object containing useful information about the etcd service running. For example:
        ```
        {
            "url": "http://172.16.24.4:2379",
            "service_name": "etcd"
        }
        ```
    """
    env_vars = {
        "ALLOW_NONE_AUTHENTICATION": "yes",
        "ETCD_DATA_DIR": "/etcd_data/",
        "ETCD_LISTEN_CLIENT_URLS": "http://0.0.0.0:{}".format(etcd_client_port),
        "ETCD_ADVERTISE_CLIENT_URLS": "http://0.0.0.0:{}".format(etcd_client_port),
    } | etcd_env_vars

    etcd_service_config= ServiceConfig(
        image = etcd_image,
        ports = {
            "client": PortSpec(number = etcd_client_port, transport_protocol = "TCP")
        },
        env_vars = env_vars,
        files={
            env_vars["ETCD_DATA_DIR"]: Directory(
                persistent_key="etcd_data_directory",
            ),
        },
        ready_conditions = ReadyCondition(
            recipe = ExecRecipe(
                command = ["etcdctl", "get", "test"]
            ),
            field = "code",
            assertion = "==",
            target_value = 0
        )
    )

    etcd = plan.add_service(name = etcd_name, config = etcd_service_config)

    return struct(
        url="http://{}:{}".format(etcd.ip_address, etcd_client_port),
        service_name=etcd_name,
    )
