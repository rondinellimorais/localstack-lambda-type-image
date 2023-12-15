FROM public.ecr.aws/lambda/python:3.9 AS devtools

# build and install python dependencies
ARG FUNCTION_DIR
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY ${FUNCTION_DIR}/requirements.txt ./
RUN pip install -r requirements.txt

# final build
FROM public.ecr.aws/lambda/python:3.9 AS build-image
ARG FUNCTION_DIR
ARG SOURCE_DIR

# configure python dependencies
RUN mkdir -p /opt/python
COPY --from=devtools /opt/venv /opt/venv

# copy python files
COPY ${FUNCTION_DIR}/*.py ./

# entry point
CMD ["handler.run"]