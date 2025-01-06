import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { verifyEmail } from "../api/auth";

const VerifyEmail = () => {
  const { token } = useParams();
  const [message, setMessage] = useState("");

  useEffect(() => {
    const verify = async () => {
      try {
        const response = await verifyEmail(token);
        setMessage(response.message);
      } catch (error) {
        setMessage(error.response?.data?.message || "Verification failed");
      }
    };
    verify();
  }, [token]);

  return <div>{message ? <p>{message}</p> : <p>Verifying...</p>}</div>;
};

export default VerifyEmail;
