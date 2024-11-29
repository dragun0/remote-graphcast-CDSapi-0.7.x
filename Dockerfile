FROM runpod/pytorch:2.1.1-py3.10-cuda12.1.1-devel-ubuntu22.04 
# FROM runpod/pytorch:2.1.1-py3.10-cuda12.1.1-devel-ubuntu22.04

# Update the LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/nvidia/lib:/usr/local/nvidia/lib64

RUN pip uninstall -y torch

ADD requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install -U "jax[cuda12_pip]==0.4.20" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
# if this does not work try ==0.4.20
#RUN pip install -U "jax[cuda12_pip]<0.4.24" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html


COPY remote_graphcast ./remote_graphcast
ADD start.sh ./
RUN chmod +x ./start.sh
# in case the file was saved on windows, this makes it unix compatible
RUN sed -i -e 's/\r$//' start.sh 


CMD ["./start.sh"]
