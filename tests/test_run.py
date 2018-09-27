# -*- coding: utf-8 -*-

import pytest
import docker as Docker

docker = Docker.from_env()


def test_wont_run_without_archive():
    with pytest.raises(Docker.errors.ContainerError,
                       message='No /archive attached'):
        docker.containers.run(
            image='codecov/migrate',
            command='scripts/run'
        )
